# phantom-cloud-gitops
(ko) 쿠버네티스 플랫폼의 선언적 상태를 기록, GitOps의 SSOT. | (en) A repository that stores the declarative state of the Kubernetes platform, acting as the SSOT for GitOps.

## 디렉터리 구조
```
.
├── bootstrap/   # 최초 1회 수동 적용 대상 (ArgoCD 설치 values, root Application)
├── apps/        # root 앱이 동기화하는 Application / ApplicationSet 매니페스트
└── platform/    # 플랫폼 구성요소의 실제 매니페스트·values (apps/의 Application이 가리키는 곳)
```

## 동기화 흐름
1. **bootstrap**: Helm으로 ArgoCD를 설치하고 root Application을 적용한다 (수동, 최초 1회)
2. **apps**: root 앱이 이 디렉터리를 감시해 각 Application을 생성한다
3. **platform**: 각 Application이 가리키는 리소스가 클러스터에 동기화된다

이후 클러스터의 모든 변경은 이 레포의 PR → 병합으로만 반영한다.

## 경계 규칙
- 쿠버네티스 API로 관리되는 리소스만 이 레포에서 관리한다. 클러스터 밖의 인프라는 [phantom-cloud-infra](https://github.com/Phantom-s-Lab/phantom-cloud-infra)에서 관리한다.
- 비밀번호, 토큰, 공인 IP, 외부 포트, 실제 도메인은 커밋하지 않는다.

## 관련 문서
- [Phantom-cloud](https://github.com/Phantom-s-Lab/Phantom-cloud): 프로젝트 개요, 아키텍처, 패치노트
- [ADR-0001: 레포 분리](https://github.com/Phantom-s-Lab/Phantom-cloud/blob/main/adr/0001-repo-split.md)
- [ADR 목록](https://github.com/Phantom-s-Lab/Phantom-cloud/blob/main/adr/README.md)
