gh repo list anarcoiris --limit 100 --json sshUrl -q ".[].sshUrl" | while read repo; do
    git clone "$repo"
done
