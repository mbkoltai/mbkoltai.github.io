% TSS solution to transformation problem from Kliman & McGlone 1988
% this is a sequential model of production prices with simple reproduction
% unit prices are dynamical, input prices =/= output prices
% total profit = total SV, total value = total price
% output of one period is the input of the next: w1(t) = c1(t+1) + c2(t+1)
% inputs and outputs of one period not equal: : w1(t+1) = c1(t+1) + c2(t+1)

% N_t: total new value added by living labour
% x1: physical quantity of capit. goods, x2: physical quantity of consumer goods
% beta1: share of consumer goods going to workers of D1
% beta2: share of consumer goods going to workers of D2
% mu: share of consumer goods going to capitalists, bought from revenue (private wealth)
% alpha: share of capit goods in D1 (1-alpha in  D2)

% difference equations
N_t=300; 
alpha=1/2; beta1=1/6;beta2=1/3; mu=1/2;
x1=200; x2=300;

t_vector=1:20;
p_sols=zeros(length(t_vector),2); r_sols=zeros(length(t_vector),1);
for i=1:length(t_vector)
    if i==1
        p_sols(i,:) = [1 1]; r_sols(i) = (N_t - (beta1+beta2)*x2*p_sols(i,2))/( p_sols(i,1)*x1 + (beta1+beta2)*x2*p_sols(i,2) );
    else
        p_sols(i,:) = [alpha beta1*(x2/x1); (1-alpha)*x1/x2 beta2]*(p_sols(i-1,:)')*(1+r_sols(i-1));
        r_sols(i) = (N_t - (beta1+beta2)*x2*p_sols(i,2))/( p_sols(i,1)*x1 + (beta1+beta2)*x2*p_sols(i,2) );
    end
end

%% plot
% figure1=plot(t_vector, p_sols);
subplot(1,2,1)
figure1=plot(t_vector, p_sols,'Marker','square','LineWidth',4); set(gca,'FontSize',24);
% Create xlabel
xlabel('time'); ylabel('unit price'); legend({'p_1','p_2'})
% Create line
line([0 20],[1,1],'LineStyle','--','LineWidth',2,  'Color', 'black')
title('unit prices', 'FontWeight', 'normal')

% subplot 2
% price of const capit
constcap_vect = [p_sols(:,1)*x1*alpha p_sols(:,1)*x1*(1-alpha)];
% wages
wages_vect = [p_sols(:,2)*x2*beta1 p_sols(:,2)*x2*beta2];
% sectoral surplus value
surplusval_vect = [N_t*beta1/(beta1+beta2) - beta1*x2*p_sols(:,2) ...
                            N_t*beta2/(beta1+beta2) - x2*p_sols(:,2)*beta2];
% cost price
costprice_vector = constcap_vect  + wages_vect;
% sectoral profit
profit_vector = [costprice_vector(:,1).*r_sols costprice_vector(:,2).*r_sols];
% output (total price)
output_price = profit_vector + costprice_vector;
revenue = mu*x2*p_sols(:,2);

subplot(1,2,2);
% sum(output_price,2) sum(surplusval_vect,2) sum(profit_vector ,2)
plot(t_vector, [ sum(output_price,2)/sum(output_price(1,:)), ... % wage share: sum(wages_vect,2)./sum(output_price,2), ...
    sum(costprice_vector,2)/sum(costprice_vector(1,:))... % sum(profit_vector,2)./sum(costprice_vector,2) ...
   [sum(profit_vector(1:end-1,:),2)./sum(revenue(2:end),2); NaN ] ],...
'Marker','square','LineWidth',4); set(gca,'FontSize',24)
title('rates', 'FontWeight', 'Normal');
legend({'output(t)/output(t=0) (price)','cost price(t)/cost price(t=0)', 'profit(t)/revenue(t+1)'}) % , 'rate of surplus value'
xlabel('time');
%% revenue(t) =  output(t-1) - cost(t)

plot(t_vector(2:end), sum(output_price(1:end-1,:) - costprice_vector(2:end,:),2) ,'Marker','square','LineWidth',4); set(gca,'FontSize',24)
hold on;
plot(t_vector(2:end), revenue(2:end,:) ,'Marker','o','LineWidth',4,'LineStyle','--'); set(gca,'FontSize',24); hold off;

%% try different initial values
t_vector=1:20;
p_sols=zeros(length(t_vector),2); r_sols=zeros(length(t_vector),1);
initval_vector = [ones(1,2); [normrnd(1.14,0.2,5,1) normrnd(1,0.2,5,1) ]];
for init_val_counter = 1:size(initval_vector,1)
for i=1:length(t_vector)
    if i==1
        p_sols(i,:) = initval_vector(init_val_counter,:); % [1 1]
        r_sols(i) = (N_t - (beta1+beta2)*x2*p_sols(i,2))/( p_sols(i,1)*x1 + (beta1+beta2)*x2*p_sols(i,2) );
    else
        p_sols(i,:) = [alpha beta1*(x2/x1); (1-alpha)*x1/x2 beta2]*(p_sols(i-1,:)')*(1+r_sols(i-1));
        r_sols(i) = (N_t - (beta1+beta2)*x2*p_sols(i,2))/( p_sols(i,1)*x1 + (beta1+beta2)*x2*p_sols(i,2) );
    end
end
p_sols_initvals(:,:,init_val_counter)=p_sols; 
end

subplot(1,2,1); plot(t_vector, squeeze(p_sols_initvals(:,1,:)),'Marker','square','LineWidth',4); set(gca,'FontSize',24); title('p_1', 'FontWeight', 'Normal');
xlabel('time'); ylim_vals=[floor(min(p_sols_initvals(:))*10)/10 ceil(max(p_sols_initvals(:))*10)/10]; ylim(ylim_vals); hold on; 
plot(t_vector, repelem(1,length(t_vector)), '--','LineWidth',2,'Color',[0 0 0])
subplot(1,2,2); plot(t_vector, squeeze(p_sols_initvals(:,2,:)),'Marker','square','LineWidth',4); set(gca,'FontSize',24); title('p_2', 'FontWeight', 'Normal');
xlabel('time'); ylim(ylim_vals); hold on; plot(t_vector, repelem(1,length(t_vector)), '--','LineWidth',2,'Color',[0 0 0])

%% steady state solution

syms p1 p2 alpha beta1 beta2 x1 x2 N_t
r=(N_t - (beta1+beta2)*x2*p2)/(p1*x1 + (beta1+beta2)*x2*p2);
p_sym_sols=solve([p1;p2] == [alpha beta1*(x2/x1); (1-alpha)*x1/x2 beta2]*[p1;p2]*(1+r),[p1 p2]);

N_t=300; 
alpha=1/2;
beta1=1/6;beta2=1/3; mu=1/2;
x1=200; x2=300;

eval(p_sym_sols.p2)