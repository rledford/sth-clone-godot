class_name Scaling


static func logarithmic_growth(base: float, growth: float, level: int) -> float:
	return base + (growth * log(level + 1))


static func logarithmic_decay(base: float, decay: float, level: int) -> float:
	return max(0, base - (decay * log(level + 1)))


static func exponential_growth(base: float, growth: float, level: int) -> float:
	return base * pow(growth, level)


static func exponential_decay(base: float, decay: float, level: int) -> float:
	return max(0, base * pow(1 - decay, level))
