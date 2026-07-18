load('src/field_utils.sage')
load('src/fiat_shamir.sage')

class NonInteractiveProver:
    def __init__(self, poly, num_vars, R):
        self.poly = poly
        self.num_vars = num_vars
        self.R = R
        self.vars = list(R.gens())

    def get_round_poly(self, round_idx, r_prev):
        field = self.R.base_ring()
        rem_vars = self.num_vars - round_idx - 1
        
        p = self.poly
        for i in range(round_idx):
            p = p.subs({self.vars[i]: r_prev[i]})

        deg = self.poly.degree(self.vars[round_idx])
        S = PolynomialRing(field, 't')
        t = S.gen()

        points = []
        for val in range(deg + 1):
            p_val = p.subs({self.vars[round_idx]: val})
            if rem_vars > 0:
                cube = boolean_hypercube(rem_vars)
                s = 0
                for pt in cube:
                    sub = {self.vars[round_idx + 1 + k]: pt[k] for k in range(rem_vars)}
                    s += p_val.subs(sub)
            else:
                s = p_val
            points.append((field(val), field(s)))

        return S.lagrange_polynomial(points)

    def prove(self):
        field = self.R.base_ring()
        claimed_sum = sum_over_hypercube(self.poly, self.vars)

        tr = Transcript("sumcheck")
        tr.append(claimed_sum)

        polys = []
        r_vals = []
        for j in range(self.num_vars):
            g_j = self.get_round_poly(j, r_vals)
            polys.append(g_j)
            tr.append(g_j)
            r_j = tr.get_challenge(field)
            r_vals.append(r_j)

        return claimed_sum, polys


class NonInteractiveVerifier:
    def __init__(self, num_vars, R, poly):
        self.num_vars = num_vars
        self.R = R
        self.poly = poly
        self.vars = list(R.gens())

    def verify(self, claimed_sum, round_polys):
        field = self.R.base_ring()
        
        tr = Transcript("sumcheck")
        tr.append(claimed_sum)

        curr_claim = field(claimed_sum)
        r_vals = []

        for j in range(self.num_vars):
            g_j = round_polys[j]
            
            # Check g_j(0) + g_j(1) == C_{j-1}
            val_0 = field(g_j(0))
            val_1 = field(g_j(1))
            if val_0 + val_1 != curr_claim:
                return False

            tr.append(g_j)
            r_j = tr.get_challenge(field)
            r_vals.append(r_j)
            curr_claim = field(g_j(r_j))

        # final check
        sub = {self.vars[i]: r_vals[i] for i in range(self.num_vars)}
        oracle = field(self.poly.subs(sub))
        if oracle != curr_claim:
            return False

        return True
