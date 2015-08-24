#! /bin/sh

N=6
SSH_KEY=$HOME/.ssh/id_rsa

NSEQ=`seq 1 $N`

if [ -f $HOME/.initialized ]; then
    exit 0
fi

# Generate ssh keys
rm -f $SSH_KEY
ssh-keygen -q -t rsa -N '' -f $SSH_KEY

# Add the ssh public key to authorized_keys
for i in $NSEQ; do
    $HOME/bin/ssh-copyid.expect hibari$i
done

# Add other Hibari hosts to /etc/hosts
for i in $NSEQ; do
    rm -f /tmp/hosts.add$i
    for j in $NSEQ; do ### add others to /tmp/hosts.add$i
        if [ $i -ne $j ]
        then
            echo `grep hibari$j /etc/hosts` >>  /tmp/hosts.add$i
        fi
    done;
    scp -o "StrictHostKeyChecking no" /tmp/hosts.add$i hibari$i:/tmp/hosts.add$i ;
    ssh -o "StrictHostKeyChecking no" hibari$i \
        "cat /tmp/hosts.add$i | sudo tee -a /etc/hosts > /dev/null"
done

touch $HOME/.initialized
