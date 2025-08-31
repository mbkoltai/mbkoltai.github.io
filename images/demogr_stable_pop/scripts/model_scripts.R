# model scripts
# LOAD PACKAGES
l_packs <- list()
l_packs$packages <- c("tidyverse", "zoo", "tools","lhs", "httr", "tictoc", "wpp2019","deSolve", "glue")
# Check and install missing packages
l_packs$installed <- l_packs$packages %in% installed.packages()[, "Package"]
if (any(!l_packs$installed)) { install.packages(l_packs$packages[!l_packs$installed]) }
# Load the packages
lapply(l_packs$packages, library, character.only=T); rm(l_packs)
# package conflicts
# conflicted::conflict_prefer("select", "dplyr")
# conflicted::conflict_prefer("filter", "dplyr")
# conflicted::conflict_prefer("lag", "dplyr")
lapply(c("select", "filter", "lag"), function(x) conflicted::conflict_prefer(x, "dplyr")) # invisible()
# load functions
source("functions.R")

# plotting settings
l_plot <- list()
l_plot$standard_theme <- theme( # for publ plots
                        plot.title=element_text(hjust=0.5,size=22),
                        axis.text.x=element_text(size=15,angle=90,vjust=1/2),
                        axis.text.y=element_text(size=15),
                        axis.title.x=element_text(size=20),
                        axis.title.y=element_text(size=20),
                        strip.text=element_text(size=22),
                        legend.text=element_text(size=20),
                        legend.title=element_text(size=22),
                        text=element_text(family="sans") )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# constant births

# death rates
l_par <- list(d_age=1, birth=1, n_age=110)

# this only contains HICs, so to get full data need to
l_par$full_death_rate_data <- bind_rows(
read_csv("annual-deaths-by-age/annual-deaths-by-age.csv") %>% 
    select(!Code) %>% 
    pivot_longer(!c(Entity,Year),names_to="age_gr") %>%
    mutate(type="deaths"),
read_csv("population-by-five-year-age-group/population-by-five-year-age-group.csv") %>% 
    select(!Code) %>% pivot_longer(!c(Entity,Year),names_to = "age_gr") %>%
    mutate(type="pop")
  ) %>%
  mutate(
    age_range = str_extract(age_gr, "Age: ?\\d{1,3}(?:-\\d{1,3})?"),
    age_numbers = str_extract(age_range, "\\d{1,3}(?:-\\d{1,3})?"),
    age_min = if_else(str_detect(age_numbers, "-"),
                      as.numeric(str_extract(age_numbers, "^\\d+")),
                      as.numeric(age_numbers)),
    age_max = if_else(str_detect(age_numbers, "-"),
                      as.numeric(str_extract(age_numbers, "\\d+$"))+1,
                      age_min+1),
    age_mid = (age_min + age_max) / 2
  ) %>% select(!age_gr) %>%
  pivot_wider(names_from=type) %>%
  mutate(value=1e3*deaths/pop)

# for HICs rate already calculated
l_par$death_rates_data <- fcn_read_mort_rates(
  file_name="annual-death-rate-by-age-group/annual-death-rate-by-age-group.csv",
  cntr_name = "France")

# fit except the first few age groups
l_par[c("log_death_rate_model","log_death_rate_coeffs")] <- fcn_log_fit_mort_rates(
  l_par_death_rates_data = l_par$death_rates_data)

# check data
if (F) {
with(l_par$death_rates_data,plot(age_mid,log(value/1e3),type="b"))
# model fit
with( c(list(age=l_par$death_rates_data$age_mid), l_par$log_death_rate_coeffs), 
  lines(age, interc+b_lin*age+b_quadr*age^2,col="blue"))
}

# interpolate mort rates
l_par$death_rates_interp <- fcn_death_rates_interp(list_par=l_par,
                            l_par_death_rates_data=l_par$death_rates_data)

# PLOT
# mortality rates
if (F) {
png("mort_rate_approx.png",width=30,height=18,units = "cm",res = 100)
with(l_par$death_rates_data,plot(age_mid,log(value/1e3),type="b",xlab="age",
  ylab="log(mortality rate per person)",xlim=c(0,110),ylim=c(-10,-0.1)))
text(10,-4, "estimates: France 2022")   # add label at (x = 5, y = 5)
lines((1:110)-1/2, log(l_par$death_rates_interp),col="blue",type="b",cex=1/2)
text(10,-3, "inter- and extrapolation",col="blue")   # add label at (x = 5, y = 5)
dev.off()
}

# ageing matrix
l_par$K_age <- with(l_par, diag(-rep(d_age,n_age)))
l_par$K_age[row(l_par$K_age)==col(l_par$K_age)+1] <- l_par$d_age
# DEATH MATRIX
l_par$K_death <- diag(l_par$death_rates_interp)
# stationary sol
l_par$stat_sol_unnorm <- with(l_par, solve(-(K_age-K_death)) %*% c(birth,rep(0,n_age-1)) )
l_par$stat_sol_norm <- with(l_par,stat_sol_unnorm/sum(stat_sol_unnorm))
l_par$stat_sol_approx <- data.frame(
                            age=1:110, 
                            perc_pop=100*with(list(prop_vals=unlist(lapply(1:110, \(x) 
                              with(list(a=-11.2,b=0.1,i=1:x), 1/prod((1+exp(a+b*i)) ) ) ))),
                              prop_vals/sum(prop_vals) ) )
# plot
data.frame(age=factor(1:l_par$n_age), perc_pop=l_par$stat_sol_norm*100) %>%
ggplot(aes(x=perc_pop,y=age)) + 
  geom_bar(stat="identity") +
  geom_line(data=l_par$stat_sol_approx,aes(color="approximate\nsolution"),linewidth=1) +
  xlab("% population") + ylab("age") +
  ggtitle("stationary age pyramid with constant birth rate") +
  scale_color_manual(name=NULL, values=c("approximate\nsolution"="red")) +
  scale_x_continuous(breaks=(0:12)/10) +
  scale_y_discrete(breaks = function(x) x[as.numeric(x) %% 5 == 0]) +
  theme_bw() + l_plot$standard_theme + theme(
    legend.position.inside=c(0.95,0.95), # x, y in [0, 1] (from bottom-left)
    legend.justification=c("right", "top"), # anchor point of the legend box
    legend.background=element_rect(fill="white",color="black") )
# SAVE
if (F) {
ggsave("constant_birth_age_struct_exact_approx.png", width=33,height=22,units="cm")
}

# taking the log
plot(log(c(l_par$stat_sol_unnorm)))
lines(with(list(a=-11.2,b=0.1,x=1:110), -x*log(1+exp(a+b*x) ) ),col="red")

# run ODE
l_sol=list()
tic(); l_sol$out_const_birth <- ode(y=c(rep(0,l_par$n_age)), times=seq.default(0,200,1/2), 
                 func=demog_mod_const_births, parms=l_par); toc()
# compare dyn and algebr sol
plot(tail(l_sol$out_const_birth,1)[-1]/sum(tail(l_sol$out_const_birth,1)[-1]),ylab="prop. pop",ylim=c(0,0.015))
lines(l_par$stat_sol_norm,col="red")
# with(list(t_sel=150), lines(l_sol$out[t_sel,-1]/sum(l_sol$out[t_sel,-1]), col="blue"))

# effect of init conds
l_sol$const_birth_initcond_sensit <- list()
for (k_sens in 1:6) {
tic()
  l_sol$const_birth_initcond_sensit[[k_sens]] <- with(
            list(t_vals=c(1,10,50,200), init_val=0+k_sens*0.4-0.2),
                  ode(y=init_val*exp(-(1:l_par$n_age)/100), # c(rep(init_val,l_par$n_age))
                      times=seq.default(0,300,1), 
                      func=demog_mod_const_births, parms=l_par)[t_vals,-1] %>%
      as.data.frame() %>% 
      mutate(t=t_vals, init_val=init_val ) %>%
    pivot_longer(!c(t,init_val),names_to = "age") ) %>% mutate(age=as.numeric(age))
toc()
}

# PLOT
with(list(n_t=length(unique(l_sol$const_birth_initcond_sensit[[1]]$t))),
l_sol$const_birth_initcond_sensit %>%
  bind_rows() %>%
  rename(`initial condition`=init_val) %>%
ggplot(aes(x=age,y=value,group=interaction(`initial condition`,t),color=factor(t))) +
  facet_wrap(~`initial condition`,labeller=label_both) + 
  geom_line(linewidth=1,alpha=2/3) + 
  geom_point(data=data.frame(age=1:l_par$n_age,
                        value=c(tail(l_sol$out_const_birth[,-1],1))),
             aes(x=age,y=value),color="black",shape=21,inherit.aes=F,alpha=1/2) +
  # scale_color_manual(values = colorRampPalette(colors = c("red","blue"))(n_t)) +
  labs(color="t") + ylab("population size") +
  theme_bw() + l_plot$standard_theme  )
# save
if (F) {
  ggsave("const_birth_dyn_init_cond.png", width=33,height=22,units="cm")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Dynamic births

# equlibrium condition is:
# r = sum(prod((1+delta_i), i=1..j), j=k..l)
l_par$birth_cohs <- 21:40
# l_par$death_rates_interp

# fertility needed to get stationary pop
l_par$r_stable <- 1/sum(unlist(lapply(l_par$birth_cohs, \(x) 1/prod(1+l_par$death_rates_interp[1:x]))))
l_par$K_birth <- matrix(0,nrow=l_par$n_age,ncol=l_par$n_age)
l_par$K_birth[1,l_par$birth_cohs] <- l_par$r_stable

l_par$init_cond <- exp((109:0)/10) # rep(1,l_par$n_age)
# solve algebraically
# exponentiate the matrix
l_sol$stat_sol_dyn_birth_exp <- c(
  with(l_par,expm::expm( (K_age-K_death+K_birth)*200 ) %*% init_cond ) )
l_sol$age_distr_dyn_birth_exp <- with(l_sol,stat_sol_dyn_birth_exp/sum(stat_sol_dyn_birth_exp))
# plot initial cond vs stat sol
plot(l_par$init_cond); lines(l_sol$stat_sol_dyn_birth_exp,col="red")


# solve ODEs
tic(); l_sol$out_dyn_birth <- ode(
            y=c(rep(1,l_par$n_age)), 
            times=seq.default(0,200,1/2), 
            func=demog_mod_dyn_births, parms=l_par); toc()
plot(rowSums(l_sol$out_dyn_birth[,-1]),ylim = c(0,1e2),type="l")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# eigenvector calc

l_par$K_all <- with(l_par,K_birth - K_death + K_age)

# need to get left and right eigenvectors
# then we know that solution is R * L * x0
l_sol$eig_L <- eigen(t(l_par$K_all))
l_sol$vL_dom <- with(l_sol, Re(eig_L$vectors[, which.max(Re(eigen(t(l_par$K_all))$values))]))
l_sol$vR_dom <- with(l_sol, Re(eigen(l_par$K_all)$vectors[, which.max(Re(eigen(l_par$K_all)$values))]))
# L * R = 1
if (signif(with(l_sol,c(vR_dom %*% vL_dom)),5)!=1) {
  if (with(l_sol,c(vR_dom %*% vL_dom))>0) {
  l_sol$norm_fact_L_R <- sqrt(1/c(with(l_sol,vR_dom %*% vL_dom)) )
  l_sol$vL_dom <- with(l_sol,vL_dom*norm_fact_L_R)
  l_sol$vR_dom <- with(l_sol,vR_dom*norm_fact_L_R) 
      } else {
        sel_var <- with(l_sol,c("vR_dom","vL_dom")[which(any(vR_dom<0),any(vL_dom<0))])
        l_sol[[sel_var]] <- l_sol[[sel_var]]/with(l_sol,c(vR_dom %*% vL_dom))
        rm(sel_var)
  }
}
# solution
l_sol$stat_sol_dyn_birth_eigvect <- c( with(l_sol, t(t(vR_dom))  %*% vL_dom) %*% l_par$init_cond )

# age distrib at the end from 3 methods
data.frame(age=1:l_par$n_age,
          age_distr_ode_dyn_birth=c(with(list(x_end=tail(l_sol$out_dyn_birth[,-1],1)),x_end/sum(x_end))),
          age_distr_exp_dyn_birth=with(l_sol,
            stat_sol_dyn_birth_exp/sum(stat_sol_dyn_birth_exp)),
          age_distr_eigvect_dyn_birth=with(l_sol,
            stat_sol_dyn_birth_eigvect/sum(stat_sol_dyn_birth_eigvect)) ) %>%
  pivot_longer(!age) %>%
  mutate(name=gsub("age_distr_|_dyn_birth","",name)) %>%
ggplot(aes(x=age,y=100*value,color=name)) + 
  # geom_point(aes(shape=name), alpha=2/3,size=4) + 
  geom_line(aes(linetype=name),linewidth=4,alpha=2/3) +
  geom_line(data=data.frame(age=1:110, name="age_distr_ode_const_birth",
            value=c(l_par$stat_sol_norm)),color="black",linewidth=1/2) +
  scale_x_continuous(breaks = (0:22)*5) +
  theme_bw() + l_plot$standard_theme + 
  labs(color="",shape="",linetype="") +
  ylab("% of population") +
  theme(legend.position="top")
# SAVE
if (F) {
ggsave("dyn_birth_age_struct_3sols.png", width=33,height=22,units="cm")
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# age distrib of stable populations w/ different death rates

l_stable_scan <- list()
l_stable_scan$summary_stats <- data.frame()
cntrs <- c("France", "Japan", "Hungary", "Russia", "Brazil", "China", "India", "Egypt", "Nigeria")

for (cntr in cntrs) {
  message("Running: ", cntr)
  
  l_par$death_rates_data <- l_par$full_death_rate_data %>% 
    filter(grepl(cntr, Entity) & Year == 2023)
  
  l_par[c("log_death_rate_model","log_death_rate_coeffs")] <- fcn_log_fit_mort_rates(
    l_par_death_rates_data = l_par$death_rates_data)

  l_par$death_rates_interp <- fcn_death_rates_interp(
    list_par = l_par,
    l_par_death_rates_data = l_par$death_rates_data)
  # store death rate
  l_stable_scan$death_rates[[cntr]] <- l_par$death_rates_interp
  
  l_par$K_death <- diag(l_par$death_rates_interp)
  
  # Fertility and birth matrix setup
  l_par$r_stable <- 1/sum(unlist(lapply(l_par$birth_cohs, \(x) 1/prod(1 + l_par$death_rates_interp[1:x]))))
  l_par$K_birth <- matrix(0, nrow = l_par$n_age, ncol = l_par$n_age)
  l_par$K_birth[1, l_par$birth_cohs] <- l_par$r_stable
  # store overall fert rate
  l_stable_scan$fert_rate[[cntr]] <- length(l_par$birth_cohs)*l_par$r_stable*2
  
  # Run ODE
  l_sol <- list()
  l_sol$out_dyn_birth <- ode(
    y = rep(1, l_par$n_age),
    times = seq(0, 200, 0.5),
    func = demog_mod_dyn_births,
    parms = l_par
  )
  
  l_stable_scan[["age_distrib"]][[cntr]] <- c(tail(l_sol$out_dyn_birth[,-1], 1) / sum(tail(l_sol$out_dyn_birth[,-1], 1)))
  
# Summarize age bands
  l_stable_scan$summary_stats <- with(list(age_distr=l_stable_scan[["age_distrib"]][[cntr]] ), 
    rbind(l_stable_scan$summary_stats, 
    data.frame(
    country = cntr,
    `0–18` = sum(age_distr[1:18]),
    `18–70` = sum(age_distr[19:70]),
    `70+` = sum(age_distr[71:l_par$n_age])
  )) )
  
}
rm(cntr,cntrs)
colnames(l_stable_scan$summary_stats)[-1] <- c("<18","18-70","70+")
l_stable_scan[c("age_distrib", "death_rates", "fert_rate")] <- list(
    bind_rows(l_stable_scan$age_distrib) %>% mutate(n_age = 1:l_par$n_age),
    bind_rows(l_stable_scan$death_rates) %>% mutate(n_age = 1:l_par$n_age),
    bind_rows(l_stable_scan$fert_rate)
  ) 

l_stable_scan$total_death_rate <- colSums(l_stable_scan$age_distrib[,-ncol(l_stable_scan$age_distrib)] *
l_stable_scan$death_rates[,-ncol(l_stable_scan$death_rates)])

### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### 
# PLOT

with(l_stable_scan, {
  ordered_countries <- summary_stats %>%
    arrange(desc(`70+`)) %>%
    pull(country)

  age_plot_data <- age_distrib %>%
    pivot_longer(cols = -n_age, names_to = "country", values_to = "value") %>%
    rename(age = n_age) %>%
    mutate(age_group = case_when(
      age<=18~"<18",
      age<=70~"18-70",
      T~"70+" )) %>%
    mutate(country = factor(country, levels = ordered_countries))

  annots <- summary_stats %>%
    pivot_longer(!country) %>%
    mutate(name = factor(name, levels = c("<18", "18-70", "70+"))) %>%
    group_by(country, name) %>%
    summarise(value = mean(value), .groups = "drop") %>%
    mutate(label = glue("{name}: {round(value * 100, 1)}%"),
           x = case_when(
             name == "<18" ~ 18,
             name == "18-70" ~ 58,
             name == "70+" ~ 97
           ),
           y = case_when(
             name == "<18" ~ 1.7,
             name == "18-70" ~ 1.7,
             name == "70+" ~ 1.7)) %>%
    mutate(country = factor(country, levels = ordered_countries))

  age_group_colors <- c("<18" = "#1b9e77", "18-70" = "#d95f02", "70+" = "#7570b3")

  fert_death_annots <- tibble(
    country=names(l_stable_scan$total_death_rate),
    death_rate=unname(l_stable_scan$total_death_rate),
    fert_rate=as.numeric(l_stable_scan$fert_rate[1, ]) ) %>%
  mutate(
    label = glue("fert. rate: {round(fert_rate, 2)}\nann-death-per-1e3: {round(death_rate*1e3)}"),
    x = 3,  # adjust as needed
    y = 0.25  ) %>%     # adjust as needed, depends on plot scale
  mutate(country = factor(country, levels = ordered_countries))
  
  ggplot(age_plot_data, aes(x = age, y = value*100, group = age_group, fill = age_group)) +
    geom_area(alpha = 0.3, position = "identity") +      # shaded area under curves
    geom_line(aes(color = age_group), linewidth = 1) +  # colored lines on top
    facet_wrap(~country) +
    scale_fill_manual(values = age_group_colors, name = "Age group") +
    scale_color_manual(values = age_group_colors, guide="none") +
    scale_x_continuous(breaks = (0:11)*10) +
    xlab("") + ylab("% of population") +
    geom_text(data = annots,
              aes(x = x, y = y, label = label, color = name),
              inherit.aes=F,size=5.5, fontface="bold") +
    # mort and fer rates
    geom_text( data = fert_death_annots,
      aes(x = x, y = y, label = label),
      inherit.aes = F, hjust = 0, size=5) +
    theme_bw() + l_plot$standard_theme +
    theme(legend.position = "top")
})

if (F) {
 ggsave("stable_pop_3_age_group_shares.png", width=40,height=32,units="cm")
}



### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# effect of init conds
l_sol$dyn_birth_initcond_sensit <- list()
for (k_sens in 1:6) {
tic()
  l_sol$dyn_birth_initcond_sensit[[k_sens]] <- with(
            list(t_vals=c(1,10,50,200,400), init_val=0+k_sens*0.4-0.2),
                  ode(y=init_val*exp(-(1:l_par$n_age-1)/100), # rep(init_val,l_par$n_age)
                      times=seq.default(0,400,1), 
                      func=demog_mod_dyn_births, parms=l_par)[t_vals,-1] %>%
    as.data.frame() %>% 
    mutate(t=t_vals, init_val=init_val ) %>%
    pivot_longer(!c(t,init_val),names_to="age") ) %>% 
    mutate(age=as.numeric(age))
toc()
}

# PLOT
with(list(n_t=length(unique(l_sol$dyn_birth_initcond_sensit[[1]]$t))),
l_sol$dyn_birth_initcond_sensit %>%
  bind_rows() %>%
  rename(`initial condition`=init_val) %>%
ggplot(aes(x=age,y=value,group=interaction(`initial condition`,t),color=factor(t))) +
  facet_wrap(~`initial condition`,labeller=label_both) + # ,scale="free_y"
  geom_line(linewidth=1,alpha=2/3) +
  geom_point(data=l_sol$dyn_birth_initcond_sensit %>%
              bind_rows() %>% 
              filter(t==max(t)) %>%
              rename(`initial condition`=init_val),
              aes(x=age,y=value),color="black",shape=21,inherit.aes=F,alpha=1/2) +
  labs(color="t") + ylab("population size") +
  theme_bw() + l_plot$standard_theme )
# SAVE
if (F) {
 ggsave("dyn_birth_dyn_init_cond.png", width=33,height=22,units="cm")
}

### ### ### ### ### ### ### ### ### ###


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# shrinking/growing population

# GROWING pop: Nigeria

# death rates for Nigeria
l_par$death_rates_data <- l_par$full_death_rate_data %>% 
                filter(grepl("Nigeria",Entity) & Year %in% 2023)

# fit except the first few age groups
l_par[c("log_death_rate_model","log_death_rate_coeffs")] <- fcn_log_fit_mort_rates(
  l_par_death_rates_data = l_par$death_rates_data)
l_par$death_rates_interp <- fcn_death_rates_interp(list_par=l_par,
                            l_par_death_rates_data=l_par$death_rates_data)


# deaths matrix
l_par$K_death <- diag(l_par$death_rates_interp)

# stationary age distrib with Nigeria death rates
# fertility needed to get stationary pop
# l_par$r_stable <- 1/sum(unlist(lapply(l_par$birth_cohs, \(x) 1/prod(1+l_par$death_rates_interp[1:x])) ))
l_par$K_birth <- matrix(0,nrow=l_par$n_age,ncol=l_par$n_age)
l_par$K_birth[1,l_par$birth_cohs] <- 4.45/(2*length(l_par$birth_cohs))

# RUN ODE
tic(); l_sol$out_dyn_birth <- ode(
            y=rep(1e3,l_par$n_age),
            times=seq.default(0,250,1/2), 
            func=demog_mod_dyn_births, parms=l_par)
toc()

# plot final age distrib
p1 <- with(l_sol, {
  # Convert deSolve output fully to tibble
  out_dyn_tib <- as_tibble(as.data.frame(out_dyn_birth))
  time_points <- c(30, 50, 70, 100,200)
  # pick rows closest to time points
  plot_data <- out_dyn_tib[sapply(time_points, function(t) which.min(abs(out_dyn_tib$time-t))), ] %>%
    pivot_longer(cols = all_of(2:ncol(out_dyn_tib)), names_to = "age", values_to = "count") %>%
    mutate(age = as.integer(str_remove(age, "V")),
          time = factor(rep(time_points, each = length(2:ncol(out_dyn_tib)))) ) %>%
    group_by(time) %>%
    mutate(value = count / sum(count) * 100) %>%
    ungroup()
  
  last_data <- out_dyn_tib[which.min(abs(out_dyn_tib$time-250)), ] %>%
    pivot_longer(cols = all_of(2:ncol(out_dyn_tib)), names_to = "age", values_to = "count") %>%
    mutate(
      age = as.integer(str_remove(age, "V")),
      value = count / sum(count) * 100
    )
  
  # print(tail(plot_data))
  
  ggplot(plot_data, aes(x=age, y=value, color=time)) +
    geom_line(size=2,alpha=2/3) +
    geom_point(data = last_data, aes(x=age, y=value),  # , shape = "steady state"
             color="black",size=2,shape=21) +
    # scale_shape_manual(name = "", values = 1) +       # hollow circle in legend
    # annotate("text", x=88, y=5, label="steady state", hjust=0, vjust=0.5) +
    labs(x = "age",
      y = "% of total population",
      color = "time (yrs)",
      title = "Age distribution at selected time points") +
    scale_x_continuous(breaks=(0:22)*5,expand=expansion(mult=0.02)) +
    scale_y_continuous(breaks =2*((0:15)/10),expand=expansion(mult=0.02)) +
    theme_bw() + l_plot$standard_theme +
    theme(legend.position="inside",   # inside upper right
          legend.position.inside=c(0.8,0.8), plot.title=element_text(size=19),
          legend.title=element_text(size=17), legend.text=element_text(size=15),
          legend.background = element_rect(color=alpha("black", 0.5)) )
})

# SAVE
if (F) {
 ggsave("grow_pop_age_distr.png", width=33,height=22,units="cm")
}

# dynamics of age groups in time
p2 <- as_tibble(as.data.frame(l_sol$out_dyn_birth)) %>%
  pivot_longer(!time,names_to = "age",values_to = "count") %>%
  mutate(age=as.numeric(age),
         age_group=case_when(
           age>0 & age<=18 ~ "<18",
           age>18 & age<=40 ~ "18-40",
           age>40 & age<=70 ~ "40-70",.default = "70+")  ) %>%
  group_by(time, age_group) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  group_by(time) %>%
  mutate(percent = count / sum(count) * 100) %>%  # convert to % of total population
  ungroup() %>%
  filter(time>15) %>%
ggplot(aes(x = time, y = percent)) + # , color = age_group
  geom_line(alpha=4/5,size=1) +
  facet_wrap(~age_group,scale="free_y") +            # one panel per age group
  labs(x = "time (yr)",y = "% of total population",
    color = "Age group",
    title = "Dynamics of age group distribution over time"  ) +
  theme_bw() +
  scale_x_continuous(expand=expansion(mult=0.03)) +
    scale_y_continuous(expand=expansion(mult=0.04)) + # breaks=0:9*5,
    theme_bw() + l_plot$standard_theme +
    theme(legend.position="inside",   # inside upper right
          legend.position.inside = c(0.9,0.85),
          legend.background = element_rect(color=alpha("black", 0.5)), 
          plot.title=element_text(size=19),
          legend.title=element_text(size=19), legend.text=element_text(size=17))
if (F) {
 ggsave("grow_pop_age_groups_dyn.png", width=33,height=22,units="cm")
}

  
# library(cowplot)
plot_grid(p1, p2, ncol = 2, rel_widths = c(1,1), align="h", axis="tb", 
          labels=c("A","B"), label_size=18, hjust=-0.5, 
          scale = 0.9)  # slightly scale down plots to create more gap
if (F) {
 ggsave("grow_pop_combined.png", width=40,height=20,units="cm")
}

# overlay some data
if (!exists("l_data")) {
  l_data <- list()
  l_data$pop_5yr_age_group <- read_csv(
      "population-by-five-year-age-group/population-by-five-year-age-group.csv")
}

# plot with data overlaid
with(list(df_plot=left_join(
l_sol$out_dyn_birth %>%
  as.data.frame() %>%
  pivot_longer(!time,names_to="age") %>%
  mutate(age=as.numeric(age)) %>%
  group_by(time) %>%
  mutate(prop_pop=value/sum(value)) %>%
  ungroup() %>%
  mutate(age_group_num=ceiling(age/5), 
        age_group_num=ifelse(age_group_num>21,21,age_group_num)) %>%
  group_by(age_group_num,time) %>%
  summarise(prop_pop=sum(prop_pop)),
l_data$pop_5yr_age_group %>%
  filter(Entity %in% "Nigeria" & Year %in% 2023) %>%
  pivot_longer(!c(Entity,Code,Year),names_to = "age_group") %>%
  mutate(age_group=gsub("Population - Sex: all - Age: | - Variant: estimates","",age_group),
         age_group_num=as.numeric(factor(age_group,levels = unique(age_group))),
         prop_pop_data=value/sum(value)  ) ) %>%
  arrange(time,age_group_num) %>%
  filter(time %in% c(0,10,50,200,250)) ), df_plot %>%
ggplot(aes(x=age_group_num*5,y=prop_pop*100,group=time,color=factor(time))) + 
  # facet_wrap(~time) +
  geom_line(linewidth=1.25,alpha=1/2) +
  geom_point(aes(y=prop_pop_data*100,color="data"),size=4,alpha=1/5) + # ,color="red"
  ggtitle(paste0("age structure with Nigeria death and fertility rates (",
    with(l_par,r_grow*length(birth_cohs)*2),")")) +
  scale_color_manual(values=c(setNames(colorRampPalette(
                        c("#132B43", "#56B1F7"))(length(unique(df_plot$time))),
                        unique(df_plot$time)),data="red") ) + # , name=""
  labs(color="time (year)") + xlab("age") + ylab("% population") + 
  theme_bw() + l_plot$standard_theme 
)
# SAVE
if (F) {
 ggsave("age_distrib_growing pop_NIG_data.png", width=33,height=22,units="cm")
}

# DEP RATIO
with(list(df_plot=l_sol$out_dyn_birth %>%
  as.data.frame() %>%
  pivot_longer(!time,names_to="age") %>%
  mutate(age=as.numeric(age)) %>%
  group_by(time) %>%
  mutate(prop_pop=value/sum(value) # ,cumul_prop=cumsum(prop_pop)
         ) %>%
  pivot_longer(!c(time,age),names_to="type") %>%
  group_by(time,type) %>%
  summarise(under_18=sum(value[age<=18]),
            work_age_18_70=sum(value[age>18 & age<=70]),
            above_70=sum(value[age>70]) ) %>%
  pivot_longer(!c(time,type)) %>%
  mutate(type=ifelse(grepl("prop",type),"% population","million ppl"),
         value=value*ifelse(grepl("popul",type),100,1e-6) ) %>%
  filter(time<=120) ), 
  with(list(df_label=df_plot %>%
  group_by(type, name) %>%
  filter(time == max(time) & grepl("population",type)) %>%
  ungroup() %>%
  mutate(label = round(value, 1))), 
    df_plot %>%
ggplot(aes(x=time,y=value,color=name,group=name)) + 
  facet_wrap(~type,scale="free_y") +
  geom_line(linewidth=1.2) + 
  geom_point(data=df_label,size=2) +
  geom_text(data=df_label, aes(label=label),
    hjust=-0.3,vjust=0.5, show.legend=F) +
  labs(color="") + xlab("year") + ylab("") +
  scale_x_continuous(expand=expansion(mult = c(0.01,0.1))) +
  scale_y_continuous(limits=c(0,NA)) +
  theme_bw() + l_plot$standard_theme + 
  theme(legend.position="top")
  )
)

ggsave("NIG_dyn_3_groups.png", width=33,height=22,units="cm")

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Shrinking population
# Japan

# death rates for Japan
l_par$death_rates_data <- l_par$full_death_rate_data %>% 
                filter(grepl("Japan",Entity) & Year %in% 2023)

# fit except the first few age groups
l_par[c("log_death_rate_model","log_death_rate_coeffs")] <- fcn_log_fit_mort_rates(
  l_par_death_rates_data = l_par$death_rates_data)
l_par$death_rates_interp <- fcn_death_rates_interp(list_par=l_par,
                            l_par_death_rates_data=l_par$death_rates_data)


# deaths matrix
l_par$K_death <- diag(l_par$death_rates_interp)

# FERT RATE
l_par$K_birth <- matrix(0,nrow=l_par$n_age,ncol=l_par$n_age)
l_par$K_birth[1,l_par$birth_cohs] <- 1.2/(2*length(l_par$birth_cohs))

# RUN ODE
tic(); l_sol$out_dyn_birth <- ode(
            y=rep(1e6,l_par$n_age),
            times=seq.default(0,250,1/2), 
            func=demog_mod_dyn_births, parms=l_par)
toc()

# plot final age distrib
p1 <- with(l_sol, {
  # Convert deSolve output fully to tibble
  out_dyn_tib <- as_tibble(as.data.frame(out_dyn_birth))
  time_points <- c(30, 50, 70, 100,200)
  # pick rows closest to time points
  plot_data <- out_dyn_tib[sapply(time_points, function(t) which.min(abs(out_dyn_tib$time-t))), ] %>%
    pivot_longer(cols = all_of(2:ncol(out_dyn_tib)), names_to = "age", values_to = "count") %>%
    mutate(age = as.integer(str_remove(age, "V")),
          time = factor(rep(time_points, each = length(2:ncol(out_dyn_tib)))) ) %>%
    group_by(time) %>%
    mutate(value=count/sum(count)*100) %>% ungroup()
  last_data <- out_dyn_tib[which.min(abs(out_dyn_tib$time-250)), ] %>%
    pivot_longer(cols = all_of(2:ncol(out_dyn_tib)), names_to = "age", values_to = "count") %>%
    mutate(age = as.integer(str_remove(age, "V")),
          value = count / sum(count) * 100)
  
  ggplot(plot_data, aes(x=age, y=value, color=time)) +
    geom_line(size=2,alpha=2/3) +
    geom_point(data = last_data, aes(x=age, y=value),  # , shape = "steady state"
             color="black",size=2,shape=21) +
    labs(x="age",y="% of total population",
      color="time (yrs)",
      title = "Age distribution at selected time points") +
    scale_x_continuous(breaks=(0:22)*5,expand=expansion(mult=0.02)) +
    scale_y_continuous(breaks =2*((0:15)/10),expand=expansion(mult=0.02)) +
    theme_bw() + l_plot$standard_theme +
    theme(legend.position="inside",   # inside upper right
          legend.position.inside=c(0.15,0.18), plot.title=element_text(size=19),
          legend.title=element_text(size=17), legend.text=element_text(size=15),
          legend.background = element_rect(color=alpha("black", 0.5)) )
})

# SAVE
if (F) {
 ggsave("shrink_pop_age_distr.png", width=33,height=22,units="cm")
}

# dynamics of age groups in time
p2 <- as_tibble(as.data.frame(l_sol$out_dyn_birth)) %>%
  pivot_longer(!time,names_to = "age",values_to = "count") %>%
  mutate(age=as.numeric(age),
         age_group=case_when(
           age>0 & age<=18 ~ "<18",
           age>18 & age<=40 ~ "18-40",
           age>40 & age<=70 ~ "40-70",.default = "70+")  ) %>%
  group_by(time, age_group) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  group_by(time) %>%
  mutate(percent = count / sum(count) * 100) %>%  # convert to % of total population
  ungroup() %>%
  filter(time>15) %>%
ggplot(aes(x = time, y = percent)) + # , color = age_group
  geom_line(alpha=4/5,size=1) +
  facet_wrap(~age_group,scale="free_y") +            # one panel per age group
  labs(x = "time (yr)",y = "% of total population",
    color = "Age group",
    title = "Dynamics of age group distribution over time"  ) +
  theme_bw() +
  scale_x_continuous(expand=expansion(mult=0.03)) +
  # scale_y_continuous(expand=expansion(mult=0.04)) + # breaks=0:9*5,
  theme_bw() + l_plot$standard_theme +
  theme(legend.position="inside",   # inside upper right
          legend.position.inside = c(0.9,0.85),
          legend.background = element_rect(color=alpha("black", 0.5)), 
          plot.title=element_text(size=19),
          legend.title=element_text(size=19), legend.text=element_text(size=17))
if (F) {
 ggsave("shrink_pop_age_groups_dyn.png", width=33,height=22,units="cm")
}

  
# library(cowplot)
plot_grid(p1, p2, ncol = 2, rel_widths = c(1,1), align="h", axis="tb", 
          labels=c("A","B"), label_size=18, hjust=-0.5, 
          scale = 0.9)  # slightly scale down plots to create more gap
if (F) {
 ggsave("shrink_pop_combined.png", width=40,height=20,units="cm")
}


### ### ### ### 

if (F) {
with(list(df_plot=l_sol$out_dyn_birth %>%
  as.data.frame() %>%
  pivot_longer(!time,names_to="age") %>%
  mutate(age=as.numeric(age)) %>%
  group_by(time) %>%
  mutate(prop_pop=value/sum(value) # ,cumul_prop=cumsum(prop_pop)
         ) %>%
  pivot_longer(!c(time,age),names_to="type") %>%
  group_by(time,type) %>%
  summarise(under_18=sum(value[age<=18]),
            work_age_18_70=sum(value[age>18 & age<=70]),
            above_70=sum(value[age>70]) ) %>%
  pivot_longer(!c(time,type)) %>%
  mutate(type=ifelse(grepl("prop",type),"% of total population","million ppl"),
         value=value*ifelse(grepl("popul",type),100,1e-6) ) %>%
  filter(time<=150) ), 
  with(list(df_label=df_plot %>%
  group_by(type, name) %>%
  filter(time == max(time)) %>%
  ungroup() %>%
  mutate(label = round(value, 1))), 
    df_plot %>%
ggplot(aes(x=time,y=value,color=name,group=name)) + 
  facet_wrap(~type,scale="free_y") +
  geom_line(linewidth=1.2) + 
  geom_point(data=df_label,size=2) +
  geom_text(data=df_label, aes(label=label),
    hjust=-0.17,vjust=0.5,show.legend=F,size=5) + # 
  labs(color="") + xlab("year") + ylab("") +
  scale_x_continuous(expand = expansion(mult=c(0.01,0.1))) +
  scale_y_continuous(limits=c(0,NA)) +
  theme_bw() + l_plot$standard_theme + 
  theme(legend.position="top")    ) )
# SAVE 
ggsave("JAP_dyn_3_groups.png", width=33,height=22,units="cm")
}

# plot with data overlaid
with(list(df_plot=left_join(
l_sol$out_dyn_birth %>%
  as.data.frame() %>%
  pivot_longer(!time,names_to="age") %>%
  mutate(age=as.numeric(age)) %>%
  group_by(time) %>%
  mutate(prop_pop=value/sum(value)) %>%
  ungroup() %>%
  mutate(age_group_num=ceiling(age/5), 
        age_group_num=ifelse(age_group_num>21,21,age_group_num)) %>%
  group_by(age_group_num,time) %>%
  summarise(prop_pop=sum(prop_pop)),
l_data$pop_5yr_age_group %>%
  filter(Entity %in% "Japan" & Year %in% 2023) %>%
  pivot_longer(!c(Entity,Code,Year),names_to = "age_group") %>%
  mutate(age_group=gsub("Population - Sex: all - Age: | - Variant: estimates","",age_group),
         age_group_num=as.numeric(factor(age_group,levels = unique(age_group))),
         prop_pop_data=value/sum(value)  ) ) %>%
  arrange(time,age_group_num) %>%
  filter(time %in% c(40,50,200)) ), df_plot %>%
ggplot(aes(x=age_group_num*5,y=prop_pop*100,group=time,color=factor(time))) + 
  geom_line(linewidth=1.25,alpha=2/3) + # facet_wrap(~time) +
  geom_point(aes(y=prop_pop_data*100),size=4,color="red",alpha=2/5) +
  scale_color_manual(values=colorRampPalette(c("#132B43","#56B1F7"))(length(unique(df_plot$time))) ) +
  ggtitle(paste0("Japan mortality and fertility rate (",
          with(l_par,max(unique(c(K_birth)))*length(birth_cohs)*2),")") ) +
  xlab("age") + ylab("% total population") + labs(color="time") +
  theme_bw() + l_plot$standard_theme   )
# SAVE
if (F) {
 ggsave("age_distrib_shrink_JAP_data.png", width=33,height=22,units="cm")
}

### ### ### 
# PLOT annual % change
with(l_sol, {
  # reshape age-specific counts
  age_data <- as_tibble(as.data.frame(out_dyn_birth)) %>%
    pivot_longer(!time, names_to = "age", values_to = "count") %>%
    mutate(age = as.numeric(str_remove(age, "V"))) %>% filter(time > 50 & time<200)
  # compute yearly % change per age
  age_pct <- age_data %>%
    group_by(age) %>%
    arrange(time) %>%
    mutate(pct_change = (count / lag(count) - 1) * 100) %>%
    ungroup()
  # compute yearly % change for total population
  total_pct <- age_data %>%
    group_by(time) %>%
    summarise(total = sum(count), .groups = "drop") %>%
    arrange(time) %>%
    mutate(total_pct_change = (total / lag(total) - 1) * 100) 

  # plot
  ggplot(age_pct, aes(x = time, y = pct_change, color = age, group = age)) +
    geom_line() +
    geom_line(data = total_pct, aes(x = time, y = total_pct_change),
              inherit.aes = FALSE, color = "black", size = 1.2) +
    labs(x = "time (yrs)",y="yearly % change",color="age",
      title = "yearly % change in population by age (black = total)") +
    scale_x_continuous(breaks = (5:20)*10,expand = expansion(mult=0.02)) +
    scale_y_continuous(breaks = (-10:0)/4) +
    theme_bw() + l_plot$standard_theme
})
# SAVE
if (F) {
 ggsave("shrink_JAP_ann_rate.png", width=33,height=22,units="cm")
}




### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# # Dynamic births, 2 variables
# # Parameters
# l_par$coeffs <- c(
#   r=NA,     # fertility rate
#   a=1/20,     # ageing rate
#   d1=0.01,   # death rate group 1
#   d2=0.01,   # death rate group 2
#   d3=0.1     # death rate group 3
# )
# l_par$coeffs["r"] <- with(as.list(l_par$coeffs),(d1+a)*(d2+a)/a)
# 
# # Initial values for x1 (newborns), x2 (child-bearing), x3 (old)
# l_par$init <- c(x1=1, x2=2, x3=3)
# 
# # Time points
# l_par$times <- seq(0,120,by=0.5)
# 
# # ODE system
# demog_mod_dyn_birth_3var <- function(t, state, parameters) {
#   with(as.list(c(state, parameters)), {
#     dx1 <- r*x2-(d1+a)*x1
#     dx2 <- a*x1-(d2+a)*x2
#     dx3 <- a*x2-d3*x3
#     list(c(dx1, dx2, dx3))
#   })
# }
# 
# # Solve ODE
# l_sol <- list()
# l_sol$out <- ode(y=l_par$init, times=l_par$times, 
#                  func=demog_mod_dyn_birth_3var, parms=l_par$coeffs)
# 
# # Plot
# l_sol$out %>% as.data.frame() %>%
#   pivot_longer(!time) %>%
# ggplot(aes(x=time,y=value,group=name,color=name)) + 
#   geom_line() + scale_y_continuous(limits = c(0,NA)) +
#   theme_bw() + l_plot$standard_theme
