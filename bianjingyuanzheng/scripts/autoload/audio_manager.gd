# scripts/autoload/audio_manager.gd
extends Node

const SOUND_ENABLED := false  # MVP阶段禁用，后续接入

func play_bgm(_bgm_path: String) -> void:
	if not SOUND_ENABLED: return

func play_sfx(_sfx_path: String) -> void:
	if not SOUND_ENABLED: return

func stop_bgm() -> void:
	if not SOUND_ENABLED: return
