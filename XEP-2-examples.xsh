xep2dir = p'/tmp/xep-2'

mkdir -p @(xep2dir)
cd @(xep2dir)

echo 'print($ARGS)' > args.xsh
chmod +x args.xsh

echo -e 'first line\nsecond line\n' > 'file with space'

./args.xsh $(ls)

du -sh $(ls)

./args.xsh @($(ls).out)

$(ls)

$[ls]

./args.xsh @($(head -n1 /etc/passwd).split(':'))

for f in $(ls):
    print(f)
