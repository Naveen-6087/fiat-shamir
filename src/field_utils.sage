# Field and ring setup

def setup_field(prime=2^61 - 1):
    return GF(prime)

def setup_ring(field, num_vars):
    names = ['x%d' % i for i in range(num_vars)]
    R = PolynomialRing(field, names)
    return R, list(R.gens())

def boolean_hypercube(n):
    if n == 0:
        return [()]
    return [tuple((i >> k) & 1 for k in range(n)) for i in range(2^n)]

def evaluate_over_hypercube(poly, variables):
    n = len(variables)
    cube = boolean_hypercube(n)
    evals = []
    for pt in cube:
        sub = {variables[i]: pt[i] for i in range(n)}
        evals.append(poly.subs(sub))
    return evals

def sum_over_hypercube(poly, variables):
    return sum(evaluate_over_hypercube(poly, variables))
