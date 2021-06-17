function [xQ,xalpha,xdelta]=model_hybrid(lambda,weight,kappa,actions,outcome)
nq      = size(outcome,2);
nt      = size(outcome,1);

ncue = 4;
if mod(nq,ncue)~=0, error('!'); end
nrep    = nq/ncue;
lambda  = repmat(lambda,1,nrep);
weight  = repmat(weight,1,nrep);
kappa   = repmat(kappa,1,nrep);

xalpha  = [ones(1,nq);nan(nt,nq)];
q       = zeros(nq,2);
xQ      = nan(nt+1,nq);
xQ(1,:) = 0;

Apost   = lambda.*(1-lambda)*2;

for t = 1:nt
    a      = actions(t,:);    
    o      = outcome(t,:);
    idx    = sub2ind([nq 2],(1:nq)',a');
   
    A = lambda.*Apost;
    kalman = weight.*A + (1-weight);
    
    delta  = o - q(idx)';
    q(idx) = q(idx) + (kappa.*kalman.*delta)';    
    
    Apost = A + (1-lambda).*delta.^2;
       
    qq1    = q(:,1);
    qq2    = q(:,2);    
    xQ(t+1,:) = (qq1 - qq2)'; % go minus nogo
    xdelta(t,:)  = delta;    
    xalpha(t,:)  = kalman;
end

end