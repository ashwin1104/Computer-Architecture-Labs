.text

# // Ignore integer overflow for addition
# int update_alert_level(unsigned int* stockpiles, unsigned int cutoff,
#   unsigned int alert_level) {
#     int total_monster = 0;
#     for (int i = 0; i < 10; i++) {
#         total_monster += stockpiles[i];
#     }
#     if (total_monster < cutoff) {
#         return alert_level + 1;
#     } else if (total_monster == cutoff) {
#         return alert_level;
#     } else {
#         return alert_level - 1;
#     }
# }
# // a0: unsigned int *stockpiles
# // a1: unsigned int cutoff
# // a2: unsigned int alert_level

.globl update_alert_level
update_alert_level:
	li $t0, 0		# total_monster = 0
	li $t1, 0		# i = 0
	li $t2, 10	# for loop end = 10

update_alert_level_for:
	bge $t1, $t2, update_alert_level_if # !(i < for loop end)
	sll	$t3, $t1, 2 # i *= 4
	add	$t3, $a0, $t3		# $t3 = &stockpiles[i]
	lw	$t3, 0($t3)		# $t3 = stockpiles[i]
	add $t0, $t0, $t3 # total_monster = total_monster + stockpiles[i]

update_alert_level_for_inc:
		addi	$t1, $t1, 1
		j	update_alert_level_for

update_alert_level_if:
		bge $t0, $a1, update_alert_level_if_2
		addi $v0, $a2, 1
		jr $ra

update_alert_level_if_2:
		bne $t0, $a1, update_alert_level_if_3
		move $v0, $a2
		jr $ra

update_alert_level_if_3:
		li $t4, 1
		sub $v0, $a2, $t4
		jr $ra
