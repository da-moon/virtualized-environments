$IMAGE_NAME = "fjolsvin/rust-base-debian"

$BUILDER = $IMAGE_NAME.Split('/')[-1]
docker buildx use "${BUILDER}" 2>&1 | Out-Null ; if (-not $?) {
  docker buildx create --use --name "${BUILDER}"  2>&1 | Out-Null
$BUILD = 'docker buildx build'
$BUILD += ' -f base\debian.Dockerfile'
$BUILD += ' --cache-from type=registry,ref={0}:cache' -f $IMAGE_NAME
$BUILD += ' --cache-to type=registry,mode=max,ref={0}:cache' -f $IMAGE_NAME
$BUILD += ' --tag {0}:latest' -f $IMAGE_NAME
$BUILD += ' --progress=plain'
$BUILD += ' --push'
$BUILD += ' .'
Write-Host $BUILD
Invoke-Expression ($BUILD)
docker buildx use default