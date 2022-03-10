## ステージング環境で

```
ssh at025
singularity shell instance://UnicornStaging
source /opt/rh/rh-ruby25/enable
cd /opt/sakura/
RAILS_ENV=production bin/rails c
```

## 本番環境で

```
ssh at025
singularity shell instance://UnicornProduction
source /opt/rh/rh-ruby25/enable
cd /opt/sakura/
RAILS_ENV=production bin/rails c
```

## おまけ：ワンライナー
```
singularity exec instance://UnicornProduction bash -c 'source /opt/rh/rh-ruby25/enable && cd /opt/sakura && RAILS_ENV=production bin/rails c'
```
