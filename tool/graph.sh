# install lakos - see https://pub.dev/packages/lakos/install
# dart pub global activate lakos
# export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "Generate Graph dependencies"

# lakos . --no-tree -o graph.dot 
lakos .  -o graph.dot  --ignore=**/firebase_options_private.dart --ignore=**/misc.dart

fcheck --svg --svgfolder .