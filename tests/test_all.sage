# Non-interactive sumcheck tests using Fiat-Shamir

load('src/sumcheck.sage')

def test_all():
    F = setup_field()
    R, x = setup_ring(F, 3)

    # g = x0*x1 + x1*x2 + x0
    g = x[0]*x[1] + x[1]*x[2] + x[0]

    # Prover
    prover = NonInteractiveProver(g, 3, R)
    claimed, polys = prover.prove()

    # Verifier
    verifier = NonInteractiveVerifier(3, R, g)
    assert verifier.verify(claimed, polys), "Honest proof verification failed"
    print("Honest proof verified successfully")

    # Soundness: bad claimed sum
    assert not verifier.verify(claimed + 1, polys), "Verifier accepted bad sum"
    print("Verifier rejected incorrect claimed sum")

    # Soundness: corrupted round polynomial
    bad_polys = list(polys)
    # add a random offset to first round polynomial
    bad_polys[0] = bad_polys[0] + 1
    assert not verifier.verify(claimed, bad_polys), "Verifier accepted bad polynomial"
    print("Verifier rejected corrupted round polynomial")

if __name__ == '__main__':
    test_all()
