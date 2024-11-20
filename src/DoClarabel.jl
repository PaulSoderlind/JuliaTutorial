"""
    DoClarabel(P,q,A,l,u,settings=Clarabel.Settings())


Utility function to help setting up the Clarabel minimisation problem according
to the OSQP API. Basically, it transforms to Float64 and sparse (for P and A)
and creates the cones from the information vectors `l` and `u`. This function
handles only linear restrictions.

It solves `min 0.5x'P*x + q'x` subject to `l <= A*x <= u` by choosing `x`. To get an equality constraint,
set `l[i] == u[i]` and to get a one-sided restriction set `l[i] = -Inf` or `u[i] = Inf`.


# Input
- `P::Matrix`:    nxn
- `q::Vector`:    n-vector
- `A::Matrix`:    Kxn
- `l::Vector`:    K-vector, lower bounds
- `u::Vector`:    K-vector, upper bounds
- `settings::Clarabel.Settings`: eg. `Clarabel.Settings(verbose = true)`

# Remark
- In the code, each inequality restriction (l[i] <= A[i:i,:]*x <= u[i]) is transformed into
two 'less than' restrictions, `A[i:i,:]x <= u[i]` and `-A[i:i,:]x <= -l[i]`

"""
function DoClarabel(P,q,A,l,u,settings=Clarabel.Settings())

  !(l<=u) && error("l <= u is not satisfied")

  P2 = sparse(Float64.(P))              #convert to Float64 (and sparse for P and A)
  q2 = Float64.(q)

  ve = l .== u                          #indices of equality restrictions
  vi = .!ve                             #indices of inequality restrictions

  A2    = sparse(Float64.(vcat(A[ve,:],A[vi,:],-A[vi,:])))   #eq restrictions first, ineq last
  b2    = Float64.(vcat(u[ve],u[vi],-l[vi]))                 #double the ineq restrictions

  cones = Clarabel.SupportedCone[]      #build cones in a loop, simple but robust approach
  for i in 1:length(b2)
    i <= sum(ve) ? push!(cones,Clarabel.ZeroConeT(1)) : push!(cones,Clarabel.NonnegativeConeT(1))
  end

  model = Clarabel.Solver()
  Clarabel.setup!(model, P2, q2, A2, b2, cones, settings)
  result = Clarabel.solve!(model)

  x = string(result.status) == "SOLVED" ? result.x : NaN

  fnO = (;P=P2,q=q2,A=A2,b=b2,cones)

  return x, result, fnO

end
#------------------------------------------------------------------------------
