git filter-repo --commit-callback '
    commit.message = commit.message
    commit.committer_name = commit.author_name
    commit.committer_email = commit.author_email
' --force

# Luego, firma cada commit con tu clave (puedes hacer un script para reescribir con firma)