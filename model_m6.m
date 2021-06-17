function [loglik] = model_m6(params,data)
% hybrid model, valence-specific w: 8 parameters

choice   = data.choice;
outcome  = data.outcome;

ux       = @(x)(1./(1+exp(-x)));
beta     = exp(params(1));

lambda1  = ux(params(2));
weight1  = ux(params(3));
weight2   = ux(params(4));
kappa1   = ux(params(5));
lambda2  = lambda1;
kappa2   = kappa1;

bv       = params(6);
be       = params(7);
bi       = params(8);
bb       = [bv bv -bv -bv] + [be -be be -be] + [bi -bi -bi bi];

lambda    = [lambda1 lambda2 lambda1 lambda2];
weight    = [weight1 weight1 weight2 weight2];
kappa     = [kappa1 kappa2 kappa1 kappa2];

[xQ]      = model_hybrid(lambda,weight,kappa,choice,outcome);

nt        = size(choice,1);
X         = xQ(1:nt,:);
Y         = choice==1;
[loglik]  = response(X,Y,beta,bb);
end

function [F, CV]=response(X,Y,beta,bv)
nq    = size(X,2);

ncue = 4;
if mod(nq,ncue)~=0, error('!'); end
nrep = nq/ncue;
bv   = repmat(bv,1,nrep);

Y     = logical(Y);
z     = bsxfun(@plus,X*beta , bv);
f     = (1./(1+exp(-z)));
    
p     = f.*Y + (1-f).*(1-Y);
CV    = z.*Y + (-z).*(1-Y);
F     = sum(sum(log(p)));
end
