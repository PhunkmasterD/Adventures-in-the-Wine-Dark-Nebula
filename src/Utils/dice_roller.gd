class_name Dice 
extends Object

static var _rng := RandomNumberGenerator.new()

# Roll a number of dice with a number of sides and a bonus
static func roll(dice: String, bonus: int = 0) -> int:
	_rng.randomize()
	print("Rolling dice: %s" % dice)
	var dice_split = dice.split("d")
	var num_dice = int(dice_split[0])
	print("num_dice: %d" % num_dice)
	var num_sides = int(dice_split[1])
	print("num_sides: %d" % num_sides)
	var total = 0
	for i in range(num_dice):
		total += _rng.randi_range(1, num_sides)
		print("total: %d" % total)
	total += bonus
	print("final total: %d" % total)
	return total

# Roll a number of dice and keep the highest results, defaulting to 1, adding the bonus at the end
static func roll_highest(dice: String, bonus: int = 0, dice_to_keep: int = 1) -> int:
	_rng.randomize()
	print("Rolling dice: %s" % dice)
	var dice_split = dice.split("d")
	var num_dice = int(dice_split[0])
	print("num_dice: %d" % num_dice)
	var num_sides = int(dice_split[1])
	print("num_sides: %d" % num_sides)
	var rolls = []
	for i in range(num_dice):
		rolls.append(_rng.randi_range(1, num_sides))
	rolls.sort()
	var total = 0
	for i in range(dice_to_keep):
		total += rolls.pop_back()
		print("total: %d" % total)
	total += bonus
	print("final total: %d" % total)
	return total

# Roll under a target value
static func roll_under(dice: String, target: int, inclusive: bool = true) -> bool:
	var result = roll(dice)
	if inclusive:
		return result <= target
	return result < target

# Roll over a target value
static func roll_over(dice: String, target: int, inclusive: bool = true) -> bool:
	var result = roll(dice)
	if inclusive:
		return result >= target
	return result > target

# Opposed roll, rolling two sets of dice and comparing the results.
static func roll_opposed(roll_1: String, bonus_1: int, roll_2: String, bonus_2: int) -> bool:
	var result_1 = roll(roll_1, bonus_1)
	var result_2 = roll(roll_2, bonus_2)
	print("result_1: %d, result_2: %d" % [result_1, result_2])
	# Return true if the first roll is higher. Use !roll_opposed for the opposite effect. 
	return result_1 > result_2

# Generic skill check function using 1d20 + a bonus, with option to roll with advantage
static func skill_check(skill: int, difficulty: int, advantage: bool = false) -> bool:
	if advantage:
		return roll_highest("2d20", skill, 1) >= difficulty
	return roll("1d20", skill) >= difficulty

# Opposed skill check function using 1d20 + a bonus, with option to roll with advantage
static func opposed_skill_check(skill_1: int, advantage_1: bool, skill_2: int, advantage_2: bool) -> bool:
	var result_1: int
	var result_2: int
	if advantage_1:
		result_1 = roll_highest("2d20", skill_1, 1)
	else:
		result_1 = roll("1d20", skill_1)
	if advantage_2:
		result_2 = roll_highest("2d20", skill_2, 1)
	else:
		result_2 = roll("1d20", skill_2)
	return result_1 > result_2
