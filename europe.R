needs(dplyr, ggplot2, readr, tidyr)
#
# if you don't have `needs` yet, install it via install.packages("needs")
# you can also just install the needed packages yourself
# library(dplyr)
# library(ggplot2)
# library(readr)
# library(tidyr)

d <- read_csv('europe-stats.csv')

d %>% ggplot(aes(x=date)) +
  geom_ribbon(aes(ymin=0, ymax=0-dry3), fill='#b35806') +
  geom_ribbon(aes(ymin=0-dry3, ymax=0-dry3-dry2), fill='#f1a340') +
  geom_ribbon(aes(ymin=0-dry3-dry2, ymax=0-dry1-dry2-dry3), fill='#fee0b6') +
  geom_ribbon(aes(ymin=0, ymax=wet3), fill='#2166ac') +
  geom_ribbon(aes(ymin=wet3, ymax=wet3+wet2), fill='#67a9cf') +
  geom_ribbon(aes(ymin=wet3+wet2, ymax=wet1+wet2+wet3), fill='#d1e5f0') +
  scale_x_date(date_breaks = '2 years', date_labels = '%Y', limits = ) +
  scale_y_reverse() +
  geom_hline(aes(yintercept=0)) +
  theme_minimal()

# scale_x_continuous(breaks = c(1, sapply(seq(1,11), function(i) 1+sum(days_in_month(seq(i))))),labels = month.abb)
ls = 0.015

dry.sm <- d %>%
  mutate(dry=dry1+dry2+dry3) %>%
  select(dry, date) %>%
  mutate(dry.loess=predict(loess(dry ~ as.numeric(date), span=ls, data=.), se=T)$fit,
         dry.loess.se=predict(loess(dry ~ as.numeric(date), span=ls, data=.), se=T)$se.fit) %>%
  mutate(date2=paste0('2019-',strftime(date, '%m-%d')),
         day=as.numeric(strftime(as.Date(date2), '%j')),
         year=as.numeric(strftime(date, '%Y'))) %>%
  select(-date)
#%>%
#  mutate(day=as.Date(strptime(paste0('2019-',day), '%Y-%j')))

#  write_csv('dry.csv')
dry.sm %>%
  mutate(day=as.Date(strptime(paste0('2019-',day), '%Y-%j'))) %>%
  ggplot(aes(x=day, y=dry.loess, color=year, group=year)) +
  scale_x_date(date_labels = '%b') +
  geom_ribbon(aes(ymin=dry.loess-dry.loess.se, ymax=dry.loess+dry.loess.se), color=F, alpha=0.1) +
  geom_line()


dry.sm %>%
  bind_rows(dry.sm %>% filter(day==1) %>% mutate(day=365, year=year-1)) %>%
  filter(year>=1995) %>%
  mutate(dry.area=dry.loess*100) %>%
  select(dry.area, day, year) %>%
  spread(year, dry.area) %>%
  mutate(day=as.Date(strptime(paste0('2019-',day), '%Y-%j'))) %>%
  write_csv('dry.csv')


