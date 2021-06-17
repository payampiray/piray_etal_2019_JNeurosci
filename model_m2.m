function [loglik,xalf,xdelta,CV] = model_m2(params,data)
% hybrid model: 7 parameters

% % % data      = load(fullfile(getdefaults('pipedir'),'data.mat')); data = data.data{1};
% % % params    = randn(1,7);


choice   = data.choice;
outcome  = data.outcome;

ux       = @(x)(1./(1+exp(-x)));
beta     = exp(params(1));

lambda1  = ux(params(2));
weight1  = ux(params(3));
kappa1   = ux(params(4));
weight2  = weight1;
lambda2  = lambda1;
kappa2   = kappa1;

bv       = params(5);
be       = params(6);
bi       = params(7);
bb       = [bv bv -bv -bv] + [be -be be -be] + [bi -bi -bi bi];

lambda    = [lambda1 lambda2 lambda1 lambda2];
weight    = [weight1 weight2 weight1 weight2];
kappa     = [kappa1 kappa2 kappa1 kappa2];

[xQ,xalf,xdelta] = model_hybrid(lambda,weight,kappa,choice,outcome);

nt       = size(choice,1);
X        = xQ(1:nt,:);
Y        = choice==1;
[loglik,CV]   = response(X,Y,beta,bb);
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
