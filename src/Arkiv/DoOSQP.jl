"""
  DoOSQP(P,q,A,l,u,settings)

Utility function to help setting up the minimisation problem according
to the OSQP API. Basically, it transforms to Float64 and sparse (for P and A)
and extracts the solution.

It solves `min 0.5θ'P*θ + q'θ` subject to `l <= A*θ <= u`.


# Input
- `P::Matrix`:      nxn
- `q::Vector`:      n-vector
- `A::Matrix`:      Kxn
- `l::Vector`:      K-vector
- `u::Vector`:      K-vector
- `settings::Dict`: eg. Dict(:verbose => true)

"""
function DoOSQP(P,q,A,l,u,settings)

  P2 = sparse(Float64.(P))              #convert to Float64 (and sparse for P and A)
  q2 = Float64.(q)
  A2 = sparse(Float64.(A))
  l2 = Float64.(l)
  u2 = Float64.(u)

  model = OSQP.Model()
  OSQP.setup!(model; P=P2, q=q2, A=A2, l=l2, u=u2, settings...)
  result = OSQP.solve!(model)

  x = result.info.status == :Solved ? result.x : NaN

  return x, result

end
#------------------------------------------------------------------------------
