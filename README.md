# docker-hbuilderx
HBuilderX docker image form uapp and common uniapp development

## build
```sh
docker build -t docker-hbuilderx .
```

## test

```sh
# 运行容器并进入内部
docker run --rm -it docker-hbuilderx

# 使用 uapp 命令创建示例项目
uapp new demo1

# 进入demo1 项目
cd demo1 && npm i
# 执行编译命令
uapp run build:app --release __UNI__ECA8F4D.wgt


```

cd ./unpackage/resources/__UNI__ECA8F4D/www/ && zip -r -q -o ../../../__UNI__ECA8F4D.wgt . && cd ../../../../