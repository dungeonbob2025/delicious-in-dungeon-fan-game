# Persistence.tscn은 씬to씬 전환에서 값을 임시로 저장하는데 사용 
# e.g) 캐릭터 선택 씬에서 선택한 캐릭터 정보 
# 	   => 게임 씬에서 선택된 캐릭터 사용
extends Node2D

var character = null
