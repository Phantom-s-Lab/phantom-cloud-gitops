# Bootstrap

클러스터에 GitOps를 처음 세울 때 **사람이 직접 한 번** 실행하는 단계입니다.
이후의 변경은 모두 Git PR로 하고, ArgoCD가 동기화합니다.

## 1. ArgoCD 설치

결정 근거: [ADR-0002](https://github.com/Phantom-s-Lab/Phantom-cloud/blob/main/adr/0002-argocd-placement.md)

| 항목 | 값 |
|---|---|
| 차트 | `argo/argo-cd` 10.11.7 (앱 v3.5.7) |
| 네임스페이스 | `argocd` |
| 배치 | x86 노드 (`kubernetes.io/arch: amd64`) |
| 구성 | non-HA, dex·notifications 비활성화 |

버전 선택 이유: ArgoCD 3.5의 공식 테스트 범위가 Kubernetes v1.33~v1.36이라,
현재 클러스터(v1.33)와 이후 목표 버전(v1.35)을 모두 포함합니다.

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

# 설치 전 렌더링 확인
helm template argocd argo/argo-cd --version 10.11.7 -n argocd \
  -f bootstrap/argocd/values.yaml | grep -E 'kind: (Deployment|StatefulSet)' -A3 | grep name:

# 설치
helm install argocd argo/argo-cd --version 10.11.7 -n argocd --create-namespace \
  -f bootstrap/argocd/values.yaml
```

## 2. 설치 확인

```bash
# 모든 파드가 Running이고 x86 노드에 배치됐는지
kubectl get pods -n argocd -o wide

# 대기 상태 리소스 사용량 (ADR-0002 근거로 기록)
kubectl top pods -n argocd
```

## 3. UI 접속과 초기 비밀번호

```bash
# 초기 admin 비밀번호
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo

# UI 접속 (https://localhost:8080, 사용자 admin)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

로그인 후 **User Info → Update Password**에서 비밀번호를 바꾸고, 초기 비밀번호 Secret을 삭제합니다.

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

## 4. root 앱 적용 (App-of-Apps)

결정 근거: [ADR-0005](https://github.com/Phantom-s-Lab/Phantom-cloud/blob/main/adr/0005-app-of-apps-applicationset.md)

root 앱은 `apps/` 디렉터리를 동기화합니다. 이후 앱 추가·변경·삭제는 `apps/`와 `platform/`을 PR로 수정합니다.

```bash
# 최초 1회만 수동 적용
kubectl apply -f bootstrap/root.yaml

# root와 하위 앱 상태 확인 (Synced / Healthy)
kubectl get applications -n argocd
```

## 다음 단계
- ArgoCD 자기 관리(self-managed) 전환: 이후 ArgoCD 설정 변경은 이 values.yaml을 PR로 수정
