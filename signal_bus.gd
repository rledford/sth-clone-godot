extends Node

signal game_over(wave: int)
signal start_new_game

signal player_hit(damage: int)
signal player_died
signal player_health_changed(health: int, max_health: int)
signal player_ammo_changed(ammo: int)

signal enemy_died(coins: int)

signal coins_changed(coins: int)

signal shot_hit_ground(global_position: Vector2)

signal open_upgrade_menu
signal close_upgrade_menu

signal register_upgrade(upgrade: Upgrade)

signal break_started(break_time: float)
signal break_timer_change(time_left: float)
signal wave_started(wave: int)

signal weapon_unlocked(weapon_name: String)
signal weapon_changed(weapon_name: String)

signal weapon_hotbar_clicked(weapon_name: String)
signal turret_placed(turret: Turret)

signal stronghold_vacant
signal stronghold_full
signal stronghold_max_level_reached

signal upgrade_completed
