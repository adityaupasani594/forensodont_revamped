from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.bootstrap import DEMO_EMAIL, DEMO_PASSWORD, init_dev_environment
from app.api.v1 import auth, cases, opg, match, report, review

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    payload = {
        "message": "Welcome to Forensodont Multimodal OPG Intelligence API",
        "version": "1.0.0",
        "track": "Vision & Multimodal AI",
    }
    if settings.ENVIRONMENT != "production":
        payload["demo_login"] = {
            "email": DEMO_EMAIL,
            "password": DEMO_PASSWORD,
        }
    return payload

@app.on_event("startup")
async def startup_event():
    if settings.ENVIRONMENT != "production":
        await init_dev_environment()

# Include routers
app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(cases.router, prefix=f"{settings.API_V1_STR}/cases", tags=["cases"])
app.include_router(opg.router, prefix=f"{settings.API_V1_STR}/opg", tags=["opg"])
app.include_router(match.router, prefix=f"{settings.API_V1_STR}/match", tags=["match"])
app.include_router(review.router, prefix=f"{settings.API_V1_STR}/review", tags=["review"])
app.include_router(report.router, prefix=f"{settings.API_V1_STR}/report", tags=["report"])
