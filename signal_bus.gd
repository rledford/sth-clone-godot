extends Node

signal game_over(wave: int)
signal start_new_game

signal player_hit(damage: int)
signal player_died
signal player_health_changed(health: int)
signal player_ammo_changed(ammo: int)

signal enemy_died(coins: int)

signal coins_changed(coins: int)

signal shot_hit_ground(global_position: Vector2)


signal open_upgrade_menu
signal close_upgrade_menu

signal upgrade_purchased(upgrade_id: String, level: int)
signal attempt_upgrade(upgrade: Upgrade)
signal register_upgrade(upgrade: Upgrade)
