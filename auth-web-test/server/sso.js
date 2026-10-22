import { jwtVerify } from "jose";

export class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

export async function verifySsoToken(token, env) {
  if (!env.SSO_JWT_SECRET) {
    throw new ApiError(503, "Hãy điền SSO_JWT_SECRET trong .env và khởi động lại server.");
  }
  const algorithm = env.SSO_JWT_ALGORITHM || "HS256";
  if (!["HS256", "HS384", "HS512"].includes(algorithm)) {
    throw new ApiError(503, "SSO_JWT_ALGORITHM phải là HS256, HS384 hoặc HS512 cho shared secret.");
  }
  try {
    const { payload, protectedHeader } = await jwtVerify(
      token,
      new TextEncoder().encode(env.SSO_JWT_SECRET),
      {
        algorithms: [algorithm],
        requiredClaims: ["exp"],
        ...(env.SSO_JWT_ISSUER ? { issuer: env.SSO_JWT_ISSUER } : {}),
        ...(env.SSO_JWT_AUDIENCE ? { audience: env.SSO_JWT_AUDIENCE } : {}),
      },
    );
    return { verified: true, algorithm: protectedHeader.alg, claims: payload };
  } catch {
    throw new ApiError(401, "Token SSO không hợp lệ, sai cấu hình xác minh hoặc đã hết hạn. Nếu callback trả token Microsoft, hãy đổi qua Microsoft/me trước.");
  }
}
