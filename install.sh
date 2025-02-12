#!/usr/bin/env bash

# Check if running as root (sudo) at the start
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo or as root."
  exit 1
fi

# This install script will:
# 1) Capture the current working directory (install path).
# 2) Create (or use) a Python virtual environment in that directory.
# 3) Install the OpenAI library in the virtual environment.
# 4) Prompt the user for an API key and store it in a .env file.
# 5) Create a 'cobash' launcher script with the hard-coded path.
# 6) Make 'cobash' executable and move it to /usr/local/bin.

# ---------------------------------------------------------------
# 1) Capture the directory from which the user runs this script.
# ---------------------------------------------------------------
INSTALL_PATH="$(pwd)"

# ---------------------------------------------------------------
# 2) Create a Python virtual environment in $INSTALL_PATH/venv.
# ---------------------------------------------------------------
# Make sure Python 3 is available
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is not installed or not in PATH."
  echo "Please install Python 3 and try again."
  exit 1
fi

# Create venv if it doesn't already exist
if [ ! -d "${INSTALL_PATH}/venv" ]; then
  echo "Creating virtual environment in '${INSTALL_PATH}/venv'..."
  python3 -m venv "${INSTALL_PATH}/venv" || {
    echo "Failed to create virtual environment."
    exit 1
  }
fi

# ---------------------------------------------------------------
# 2b) Install required packages in the venv
# ---------------------------------------------------------------
echo "Installing required packages in the virtual environment..."
"${INSTALL_PATH}/venv/bin/pip" install --upgrade pip
"${INSTALL_PATH}/venv/bin/pip" install openai python-dotenv SpeechRecognition pyaudio

# ---------------------------------------------------------------
# 3) Prompt the user for an API key.
# ---------------------------------------------------------------
echo "Please enter your API key (e.g., OpenAI key):"
read -r API_KEY

if [ -z "$API_KEY" ]; then
  echo "No API key entered. Exiting..."
  exit 1
fi

# ---------------------------------------------------------------
# 4) Create a .env file storing the API key.
# ---------------------------------------------------------------
cat <<EOF > .env
OPENAI_API_KEY="$API_KEY"
EOF

# Change ownership back to the sudo user (if present), so the normal user can read it.
if [ -n "$SUDO_USER" ]; then
  chown "$SUDO_USER":"$SUDO_USER" .env
fi

chmod 600 .env 2>/dev/null || true
echo "Your API key has been saved to .env (permissions set to 600 if possible)."

# ---------------------------------------------------------------
# 5) Create the 'cobash' file with the hard-coded path.
# ---------------------------------------------------------------
cat <<EOF > cobash
#!/usr/bin/env bash

# The directory is hard-coded at install time:
SCRIPT_DIR="${INSTALL_PATH}"

# 1) Activate the virtual environment
source "\${SCRIPT_DIR}/venv/bin/activate"

# 2) Suppress ALSA/JACK warnings
export SDL_AUDIODRIVER=dummy
export ALSA_DEBUG=0
export PYTHONWARNINGS="ignore"

# 3) Export or source the API key if needed.
# We'll source the .env if present, so that environment variable is available.
# (Optional, depending on how your Python code retrieves it)
if [ -f "\${SCRIPT_DIR}/.env" ]; then
  export \$(grep -v '^#' "\${SCRIPT_DIR}/.env" | xargs)
fi

# 4) Run the Python script, suppressing stderr
"\${SCRIPT_DIR}/cobashpy" 2>/dev/null
EOF

# ---------------------------------------------------------------
# 6) Make 'cobash' executable.
# ---------------------------------------------------------------
chmod +x cobash

echo "The 'cobash' file has been created in $(pwd) with a hard-coded path."

# ---------------------------------------------------------------
# 7) Move 'cobash' to /usr/local/bin.
# ---------------------------------------------------------------
if [ -f "/usr/local/bin/cobash" ]; then
    echo "Warning: /usr/local/bin/cobash already exists. Backing up to cobash.bak"
    mv /usr/local/bin/cobash /usr/local/bin/cobash.bak
fi

if mv cobash /usr/local/bin/cobash 2>/dev/null; then
    echo "'cobash' has been moved to /usr/local/bin. You can run 'cobash' from anywhere now."
else
    echo "Failed to move 'cobash' to /usr/local/bin. Please run:
    sudo mv cobash /usr/local/bin/cobash
if you want to run 'cobash' from any directory."
fi

# Check if cobashpy exists
if [ ! -f "${INSTALL_PATH}/cobashpy" ]; then
    echo "Error: cobashpy file not found in ${INSTALL_PATH}"
    exit 1
fi

# Make cobashpy executable
chmod +x "${INSTALL_PATH}/cobashpy"
