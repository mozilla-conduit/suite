# Put common repository setup in an initfile to reduce boilerplate setup.
# Don't use a .bashrc so that, if the entrypoint needs to be skipped, you can just override CMD to be "bash" (rather
# than having to force bash to ignore the .bashrc)
if [ -f ~/.volume-initialized ]; then
  echo "Repos already initialized...\n"
else
  echo "Initializing repos...\n"
  ./clone_repositories.sh
  touch ~/.volume-initialized
fi
