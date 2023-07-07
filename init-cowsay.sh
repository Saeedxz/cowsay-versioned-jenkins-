# if [ $# -eq 0 ]; then
#   port=8081  # Default port number
# else
#   port=$1  # Use the provided port number
# fi
# docker build -t cow1 .
# docker run -d --name cowsay -p $port:$port -e PORT="$port" cow1 

# echo "Using port number: $port"

port=8081  # Default port number
version="" # Default version

while getopts ":p:v:" opt; do
  case $opt in
    p)
      port=$OPTARG
      ;;
    v)
      version=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

docker build -t cow1 .
docker run -d --name cowsay-$version -p $port:$port -e PORT="$port" cow1

echo "Using port number: $port"
echo "Using version: $version"