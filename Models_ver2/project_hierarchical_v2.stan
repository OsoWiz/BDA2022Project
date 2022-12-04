data {
  int<lower=0> N;  // number of data points
  int<lower=0> J; // number of states
  vector[J] x[N];// Magnitude of a tornado
  vector<lower=0>[J] y[N];// Average injuries caused by a tornado
}

parameters {
  real mualpha0;
  real<lower=0> salpha0;
  real mubeta0;
  real<lower=0> sbeta0;
  vector[J] alpha;
  vector[J] beta;
  real<lower=0> sigma;
}

transformed parameters {
  vector[J] mu[N];
  
  for (n in 1:N) {
    for (j in 1:J)
      mu[n, j] = x[n,j]*alpha[j]+beta[j];
  }
}

model {
  mualpha0 ~ normal(0, 100);
  salpha0 ~ normal(5, 100);;
  mubeta0 ~ normal(0, 100);
  sbeta0 ~ normal(5, 100);;
  sigma ~ inv_chi_square(0.1);
  
  for (j in 1:J) {
    alpha[j] ~ normal(mualpha0, salpha0); //prior of alpha
    beta[j] ~ normal(mubeta0, sbeta0); //prior of beta
    y[,j] ~ normal(mu[,j], sigma);
  }
}

generated quantities {
  vector[J] log_lik[N];
  
  for (n in 1:N) {
    for (j in 1:J) {
      log_lik[n, j] = normal_lpdf(y[n,j] | mu[n, j], sigma);
    }
  }
}
