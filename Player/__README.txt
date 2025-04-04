# Player 디렉토리 설명

1. Player.tscn, Player.gd
	Player 씬과 Player GDScript

2. Player.UI
	Panel:
		Options 등 GUI 목록을 띄울 때 사용될 배경용 NinePatchRect 노드.
	Options:
		Player가 레벨 업 후 업그레이드할 Normal Weapon, Critical Weapon, Passive Item 선택
		목록을 보여주는 노드.
	Weapons:	
		현재 Player가 사용하는 Weapon 목록을 보여주는 HBoxContainer 노드.
		총 4가지 무기가 제공되므로, 1개는 기본 Weapon Slot, 나머지 3개는 비어있는 Slot이 제공.
	PassiveItems:
		현재 Player의 Passive Item 리스트를 보여주는 HBoxContainer 노드.
		다만, 추후 게임 설정에 따라, PassiveItems 노드는 hiding할 수 있다..
	ProgressBar_XP:
		현재 Player의 경험치(XP)와 Level을 보여주는 노드
	Camera2D:
		Player를 따라서 카메라가 이동하므로, Player의 자식 노드로 Camera2D를 추가.
		여기서 Control-WindowFilter는 배경화면이 전환될 때, Gaussian Blur + FadeIn/Out을 위한 용도
		다만.. 어떻게 Gaussian Blur가 뒷 배경에 적용되는 원리를 아직 파악하지 못했다.
		After Effect처럼 상위 레이어에 Blur처리하면 뒷 배경이 영향을 받을 것으로 생각했는데..
		그렇다면 원리가 뭔지도 알고 싶다.
	AnimatedSprite2D:
	CollisionShape2D:
		기본 캐릭터 움직임과 움직임 충돌 영역
	HealthProgressBar:
		캐릭터 체력바
	SelfDamageHitBox:
		Enemy와 충돌 영역, 해당 영역에 Enemy가 들어오면 충돌 처리 후 데미지를 입는다.
	Timer_HitBoxRenew:
		SelfDamageHitBox에서 충돌 처리하면, Enemy가 겹쳐도 더이상 충돌 처리가 되지 않는다.
		이는 body_entered가 이미 호출되었기 때문. 따라서, SelfDamageHitBox를 비활성화했다가
		다시 활성화함으로써 Enmey 충돌 처리를 반복한다.
	Magnet:
		Pickup Items를 주울 수 있는 영역.
	
		
