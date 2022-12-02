tornadoes <- read.csv('~/notebooks/BDA/Project/tornado_modified_ver1.csv')
tornadoes <- filter(tornadoes, mag >= 0 & ns==1)
data_pooled <- data.frame(x = tornadoes$mag, y=tornadoes$inj, st=tornadoes$st) %>% 
  group_by(st, x) %>% 
  summarize(y=mean(y))
states <- data.frame(st = tornadoes$st) %>% 
  group_by(st) %>%
  summarize()

x_h <- matrix(0, nrow(states), 6)
y_h <- matrix(0, nrow(states), 6)
for (i in 1:nrow(states)){
  data_i = filter(data_pooled, st==states$st[i])
  x_h[i,1:nrow(data_i)] = data_i$x
  y_h[i,1:nrow(data_i)] = data_i$y
}

data_hx <- as.data.frame(t(x_h))
data_hy <- as.data.frame(t(y_h))

saveRDS(data_pooled, file='~/notebooks/BDA/Project/data_pooled.Rda')
saveRDS(data_hx, file='~/notebooks/BDA/Project/data_hierarchical_x.Rda')
saveRDS(data_hy, file='~/notebooks/BDA/Project/data_hierarchical_y.Rda')
