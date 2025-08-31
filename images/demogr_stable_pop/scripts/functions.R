# functions

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# solve as ODE system
# with(l_par, K_age - K_death + K_birth)
demog_mod_dyn_births <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dx_dt <- (K_age-K_death+K_birth) %*% state
    list(dx_dt)
  })
}

# constant number of births
demog_mod_const_births <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dx_dt <- c(birth,rep(0,n_age-1)) + (K_age - K_death) %*% state
    list(c(dx_dt))
  }) }

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
fcn_read_mort_rates <- function(file_name,cntr_name) {

  read_csv(file_name) %>% 
  filter(grepl(cntr_name,Entity) & Year==2022 ) %>%
  select(!Code) %>%
  pivot_longer(!c(Year,Entity),names_to = "age_gr") %>%
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
  ) %>% select(!age_gr)
  
}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# log fit for mort rates

fcn_log_fit_mort_rates <- function(
    l_par_death_rates_data,
    n_first_outl=5,
    scaling_fact=1e3) {
log_death_rate_model <- with(list(
  death_rate=log(l_par_death_rates_data$value/scaling_fact)[-(1:n_first_outl)],
  age=l_par_death_rates_data$age_mid[-(1:n_first_outl)]),
    lm(death_rate ~ age + I(age^2)) )
log_death_rate_coeffs <- setNames(nm = c("interc","b_lin","b_quadr"), 
  as.list(coef(log_death_rate_model)))

list(log_death_rate_model,log_death_rate_coeffs)

}

##
# interpolate and extrapol death rates

fcn_death_rates_interp <- function(list_par,
                                   l_par_death_rates_data,
                                   scaling_factor=1e3,
                                   max_death_rate=0.9  ) {
  
l_par_death_rates_interp <- with(list(df=l_par_death_rates_data), 
  approx(x=df$age_mid, y=df$value, 
         xout=seq(1,max(l_par_death_rates_data$age_max),by=1)-0.5,
         rule = 1) )$y/scaling_factor

if (all(is.na(l_par_death_rates_interp[1:2]))) {
  l_par_death_rates_interp[1:2] <- as.numeric(
    with(list(x=l_par_death_rates_interp), predict(lm(y ~ x, data = data.frame(x = 3:5, y = x[3:5])), 
    newdata = data.frame(x = 1:2)) ))
}

# print(l_par_death_rates_interp)
# and predict the rest
extrapol_age_range <- ceiling(max(l_par_death_rates_data$age_mid)):list_par$n_age
extrapol_vals <- with(
  c(list_par$log_death_rate_coeffs,
  list(age_range=max(l_par_death_rates_data$age_mid):list_par$n_age) ), 
  exp(interc+b_lin*age_range+b_quadr*age_range^2)  )
extrapol_vals <- extrapol_vals*(l_par_death_rates_interp[extrapol_age_range[1]]/extrapol_vals[1])
max_val_before_extrapol <- max(l_par_death_rates_interp,na.rm = T)
l_par_death_rates_interp[extrapol_age_range] <- extrapol_vals
# death rate cannot be over 1
l_par_death_rates_interp[l_par_death_rates_interp>max_death_rate] <- max_death_rate

l_par_death_rates_interp

}
