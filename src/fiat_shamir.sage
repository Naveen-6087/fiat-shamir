import hashlib

class Transcript:
    def __init__(self, label):
        self.state = hashlib.sha256(label.encode())

    def append(self, item):
        self.state.update(str(item).encode())

    def get_challenge(self, field):
        digest = self.state.digest()
        val = int.from_bytes(digest, byteorder='big')
        self.state.update(digest)
        return field(val)
