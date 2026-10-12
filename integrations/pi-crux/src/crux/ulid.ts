import { randomBytes } from "node:crypto";

const ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

/** ULID: 10 chars of time, 16 of randomness, Crockford base32. */
export function ulid(now = Date.now()): string {
	let time = "";
	let t = now;
	for (let i = 0; i < 10; i++) {
		time = ALPHABET[t % 32] + time;
		t = Math.floor(t / 32);
	}
	const bytes = randomBytes(16);
	let rand = "";
	for (let i = 0; i < 16; i++) rand += ALPHABET[bytes[i] % 32];
	return time + rand;
}
