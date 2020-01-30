#!/bin/bash

OUTPUT=/eos/user/k/kpanos/www/SOS/tests/test_plots2018/plotting

ssh lxplus710 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_dy low $OUTPUT/Original sos" &
ssh lxplus711 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_dy low $OUTPUT/Alternative alt" &

ssh lxplus712 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_tt low $OUTPUT/Original sos" &
ssh lxplus713 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_tt low $OUTPUT/Alternative alt" &

ssh lxplus714 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_dy med $OUTPUT/Original sos" &
ssh lxplus715 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_dy med $OUTPUT/Alternative alt" &

ssh lxplus716 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_tt med $OUTPUT/Original sos" &
ssh lxplus717 -o "StrictHostKeyChecking no" "./ssh-test.sh cr_tt med $OUTPUT/Alternative alt" &

exit 0
