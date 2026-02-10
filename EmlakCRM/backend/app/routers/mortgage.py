from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from typing import Optional

from app.models.user import User
from app.utils.security import get_current_user
from app.services.mortgage_service import MortgageService

router = APIRouter(prefix="/mortgage", tags=["Mortgage"])


# Request Models
class MortgageCalculateRequest(BaseModel):
    property_price: float
    down_payment_percent: float
    term_years: int
    bank_key: Optional[str] = None
    custom_rate: Optional[float] = None
    currency: str = "AZN"


class AffordabilityRequest(BaseModel):
    monthly_income: float
    monthly_expenses: float
    max_payment_ratio: float = 40.0


@router.post("/calculate")
def calculate_mortgage(
    request: MortgageCalculateRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Mortgage hesablama.

    **Body:**
    ```json
    {
        "property_price": 150000,
        "down_payment_percent": 20,
        "term_years": 30,
        "bank_key": "kapital_bank",
        "currency": "AZN"
    }
    ```

    **Response:**
    ```json
    {
        "property_price": 150000,
        "down_payment": 30000,
        "loan_amount": 120000,
        "monthly_payment": 1245.67,
        "total_payment": 448440,
        "total_interest": 328440,
        "rate": 12.0,
        "term_years": 30,
        "bank": "Kapital Bank"
    }
    ```
    """
    result = MortgageService.calculate_mortgage(
        property_price=request.property_price,
        down_payment_percent=request.down_payment_percent,
        term_years=request.term_years,
        bank_key=request.bank_key,
        custom_rate=request.custom_rate,
        currency=request.currency
    )

    return result


@router.post("/compare")
def compare_banks(
    property_price: float,
    down_payment_percent: float,
    term_years: int,
    currency: str = "AZN",
    current_user: User = Depends(get_current_user)
):
    """
    Bankları müqayisə et.

    **Parameters:**
    - property_price: 150000
    - down_payment_percent: 20
    - term_years: 30
    - currency: AZN

    **Response:**
    Banklar sıralanmış şəkildə (ən aşağı aylıq ödənişdən başlayaraq)
    """
    results = MortgageService.compare_banks(
        property_price=property_price,
        down_payment_percent=down_payment_percent,
        term_years=term_years,
        currency=currency
    )

    return {
        "total": len(results),
        "property_price": property_price,
        "down_payment_percent": down_payment_percent,
        "term_years": term_years,
        "currency": currency,
        "banks": results
    }


@router.get("/banks")
def get_all_banks(current_user: User = Depends(get_current_user)):
    """
    Bütün bankların siyahısı və şərtləri.

    **Response:**
    ```json
    {
        "kapital_bank": {
            "name": "Kapital Bank",
            "rate_azn": 12.0,
            "rate_usd": 8.0,
            "min_down_payment": 20,
            "max_term_years": 30
        }
    }
    ```
    """
    return {
        "banks": MortgageService.get_all_banks()
    }


@router.get("/schedule")
def get_payment_schedule(
    loan_amount: float = Query(..., description="Kredit məbləği"),
    annual_rate: float = Query(..., description="İllik faiz (%)"),
    term_years: int = Query(..., description="Müddət (il)"),
    current_user: User = Depends(get_current_user)
):
    """
    Ödəniş cədvəli (ilk 12 ay).

    **Parameters:**
    - loan_amount: 120000
    - annual_rate: 12.0
    - term_years: 30

    **Response:**
    ```json
    [
        {
            "month": 1,
            "date": "2024-03-01",
            "payment": 1245.67,
            "principal": 45.67,
            "interest": 1200,
            "balance": 119954.33
        }
    ]
    ```
    """
    schedule = MortgageService.generate_payment_schedule(
        loan_amount=loan_amount,
        annual_rate=annual_rate,
        term_years=term_years
    )

    return {
        "loan_amount": loan_amount,
        "annual_rate": annual_rate,
        "term_years": term_years,
        "schedule": schedule
    }


@router.post("/affordability")
def calculate_affordability(
    request: AffordabilityRequest,
    current_user: User = Depends(get_current_user)
):
    """
    İmkan hesablaması - müştəri nə qədər mortgage götürə bilər?

    **Body:**
    ```json
    {
        "monthly_income": 2000,
        "monthly_expenses": 800,
        "max_payment_ratio": 40.0
    }
    ```

    **Response:**
    ```json
    {
        "monthly_income": 2000,
        "monthly_expenses": 800,
        "available_monthly": 1200,
        "max_monthly_payment": 800,
        "recommended_property_price": 200000,
        "recommended_down_payment": 40000,
        "recommended_loan": 160000
    }
    ```
    """
    result = MortgageService.calculate_affordability(
        monthly_income=request.monthly_income,
        monthly_expenses=request.monthly_expenses,
        max_payment_ratio=request.max_payment_ratio
    )

    return result
