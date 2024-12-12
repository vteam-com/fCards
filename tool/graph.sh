# install lakos - see https://pub.dev/packages/lakos/install
# dart pub global activate lakos
# export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "Generate Graph dependencies"

rm graph.dot
rm graph.svg

# lakos . --no-tree -o graph.dot 
lakos .  -o graph.dot  --ignore=**/firebase_options_private.dart --ignore=**/misc.dart

# lakos .  -o graph.dot 
dot -Tsvg graph.dot -Grankdir=TB -Gcolor=lightgray -Ecolor="#aabbaa88" -o graph.svg

