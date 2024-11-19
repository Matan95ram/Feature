# Prompt for the IP address
$ip = Read-Host -Prompt 'Input the IP address'

# Get the output of qwinsta command for the specified IP
$qwinstaOutput = qwinsta /server:$ip

# Convert the output to an array of lines
$lines = $qwinstaOutput -split "`n"

# Filter the lines to get the one with the 'Active' state
$activeLine = $lines | Where-Object { $_ -match 'Active' }

# Split the active line into parts and get the session ID
$parts = $activeLine -split '\s+', 0, 'RegexMatch'
$sessionId = $parts[3]

# Use the session ID and IP with mstsc /shadow command
mstsc /v:$ip /shadow:$sessionId /control
