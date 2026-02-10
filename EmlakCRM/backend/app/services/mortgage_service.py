"""
Mortgage Calculator Service

Azərbaycan bankları üçün mortgage (ipoteka) hesablama servisi.
"""

from typing import Dict, List, Optional
from datetime import date, timedelta
import math


class MortgageService:
    """Mortgage hesablama servisi"""

    # Azərbaycan bankların approximate faiz dərəcələri (2024)
    BANK_RATES = {
        "kapital_bank": {
            "name": "Kapital Bank",
            "rate_azn": 12.0,  # İllik faiz (AZN)
            "rate_usd": 8.0,   # İllik faiz (USD)
            "min_down_payment": 20,  # Minimum ilkin ödəniş (%)
            "max_term_years": 30,
            "features": ["Online müraciət", "Sürətli təsdiq", "Gec ödəmə halında cərimə yoxdur (ilk 3 ay)"]
        },
        "abb_bank": {
            "name": "ABB (Azərbaycan Beynəlxalq Bankı)",
            "rate_azn": 11.5,
            "rate_usd": 7.5,
            "min_down_payment": 20,
            "max_term_years": 30,
            "features": ["Dövlət dəstəyi ilə güzəştli kredit", "İlkin ödəniş 10%-dən başlayır"]
        },
        "bank_respublika": {
            "name": "Bank Respublika",
            "rate_azn": 12.5,
            "rate_usd": 8.5,
            "min_down_payment": 25,
            "max_term_years": 25,
            "features": ["Sürətli qərar", "Çevik şərtlər"]
        },
        "AccessBank": {
            "name": "AccessBank",
            "rate_azn": 11.0,
            "rate_usd": 7.0,
            "min_down_payment": 20,
            "max_term_years": 30,
            "features": ["Ən aşağı faiz", "Döyüş iştirakçıları üçün güzəşt"]
        },
        "pasha_bank": {
            "name": "Paşa Bank",
            "rate_azn": 12.0,
            "rate_usd": 8.0,
            "min_down_payment": 20,
            "max_term_years": 30,
            "features": ["Premium xidmət", "VIP müştərilər üçün xüsusi şərtlər"]
        }
    }

    @staticmethod
    def calculate_monthly_payment(
        loan_amount: float,
        annual_rate: float,
        term_years: int
    ) -> float:
        """
        Aylıq ödənişi hesablayır (annuitet metodu).

        Formula: M = P * (r * (1 + r)^n) / ((1 + r)^n - 1)

        Args:
            loan_amount: Kredit məbləği
            annual_rate: İllik faiz dərəcəsi (%)
            term_years: Kredit müddəti (il)

        Returns:
            Aylıq ödəniş məbləği
        """
        if loan_amount <= 0 or annual_rate <= 0 or term_years <= 0:
            return 0

        # Aylıq faiz
        monthly_rate = annual_rate / 100 / 12

        # Aylıq ödəniş sayı
        num_payments = term_years * 12

        # Annuity formula
        if monthly_rate == 0:
            return loan_amount / num_payments

        monthly_payment = loan_amount * (
            monthly_rate * math.pow(1 + monthly_rate, num_payments)
        ) / (
            math.pow(1 + monthly_rate, num_payments) - 1
        )

        return round(monthly_payment, 2)

    @staticmethod
    def calculate_total_interest(
        loan_amount: float,
        monthly_payment: float,
        term_years: int
    ) -> float:
        """Ümumi faiz məbləği"""
        total_paid = monthly_payment * term_years * 12
        return round(total_paid - loan_amount, 2)

    @staticmethod
    def generate_payment_schedule(
        loan_amount: float,
        annual_rate: float,
        term_years: int,
        start_date: Optional[date] = None
    ) -> List[Dict]:
        """
        Ödəniş cədvəli yaradır (ilk 12 ay üçün).

        Returns:
            [
                {
                    "month": 1,
                    "date": "2024-03-01",
                    "payment": 1000,
                    "principal": 800,
                    "interest": 200,
                    "balance": 99200
                }
            ]
        """
        if start_date is None:
            start_date = date.today()

        monthly_rate = annual_rate / 100 / 12
        monthly_payment = MortgageService.calculate_monthly_payment(
            loan_amount, annual_rate, term_years
        )

        schedule = []
        balance = loan_amount

        # İlk 12 ay
        for month in range(1, 13):
            interest_payment = balance * monthly_rate
            principal_payment = monthly_payment - interest_payment
            balance -= principal_payment

            payment_date = start_date + timedelta(days=30 * month)

            schedule.append({
                "month": month,
                "date": payment_date.strftime("%Y-%m-%d"),
                "payment": round(monthly_payment, 2),
                "principal": round(principal_payment, 2),
                "interest": round(interest_payment, 2),
                "balance": round(max(balance, 0), 2)
            })

        return schedule

    @staticmethod
    def calculate_mortgage(
        property_price: float,
        down_payment_percent: float,
        term_years: int,
        bank_key: Optional[str] = None,
        custom_rate: Optional[float] = None,
        currency: str = "AZN"
    ) -> Dict:
        """
        Full mortgage hesablaması.

        Args:
            property_price: Property qiyməti
            down_payment_percent: İlkin ödəniş (%)
            term_years: Kredit müddəti (il)
            bank_key: Bank açarı (məs: "kapital_bank")
            custom_rate: Custom faiz dərəcəsi (əgər bank seçilməyibsə)
            currency: Valyuta (AZN və ya USD)

        Returns:
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
        """
        # İlkin ödəniş hesabla
        down_payment = property_price * (down_payment_percent / 100)
        loan_amount = property_price - down_payment

        # Faiz dərəcəsi təyin et
        rate = custom_rate
        bank_name = "Custom"

        if bank_key and bank_key in MortgageService.BANK_RATES:
            bank_info = MortgageService.BANK_RATES[bank_key]
            rate = bank_info["rate_azn"] if currency == "AZN" else bank_info["rate_usd"]
            bank_name = bank_info["name"]

        if rate is None:
            rate = 12.0  # Default

        # Hesablamalar
        monthly_payment = MortgageService.calculate_monthly_payment(
            loan_amount, rate, term_years
        )

        total_payment = monthly_payment * term_years * 12
        total_interest = total_payment - loan_amount

        return {
            "property_price": round(property_price, 2),
            "down_payment": round(down_payment, 2),
            "down_payment_percent": down_payment_percent,
            "loan_amount": round(loan_amount, 2),
            "monthly_payment": round(monthly_payment, 2),
            "total_payment": round(total_payment, 2),
            "total_interest": round(total_interest, 2),
            "interest_to_loan_ratio": round((total_interest / loan_amount) * 100, 2) if loan_amount > 0 else 0,
            "rate": rate,
            "term_years": term_years,
            "bank": bank_name,
            "currency": currency
        }

    @staticmethod
    def compare_banks(
        property_price: float,
        down_payment_percent: float,
        term_years: int,
        currency: str = "AZN"
    ) -> List[Dict]:
        """
        Bütün bankların mortgage şərtlərini müqayisə edir.

        Returns:
            Bank-lardan sıralanmış list (aylıq ödənişə görə)
        """
        results = []

        for bank_key, bank_info in MortgageService.BANK_RATES.items():
            # Min ilkin ödəniş yoxlaması
            if down_payment_percent < bank_info["min_down_payment"]:
                continue

            # Max müddət yoxlaması
            if term_years > bank_info["max_term_years"]:
                continue

            result = MortgageService.calculate_mortgage(
                property_price=property_price,
                down_payment_percent=down_payment_percent,
                term_years=term_years,
                bank_key=bank_key,
                currency=currency
            )

            result["features"] = bank_info["features"]
            results.append(result)

        # Aylıq ödənişə görə sırala (aşağıdan yuxarı)
        results.sort(key=lambda x: x["monthly_payment"])

        return results

    @staticmethod
    def get_all_banks() -> Dict:
        """Bütün bankların siyahısı və şərtləri"""
        return MortgageService.BANK_RATES

    @staticmethod
    def calculate_affordability(
        monthly_income: float,
        monthly_expenses: float,
        max_payment_ratio: float = 40.0
    ) -> Dict:
        """
        İmkan hesablaması - nə qədər mortgage götürə bilər?

        Args:
            monthly_income: Aylıq gəlir
            monthly_expenses: Aylıq xərclər
            max_payment_ratio: Max ödəniş/gəlir nisbəti (default: 40%)

        Returns:
            {
                "monthly_income": 2000,
                "monthly_expenses": 800,
                "available_monthly": 1200,
                "max_monthly_payment": 800,  # 40% of income
                "recommended_property_price": 200000,
                "recommended_down_payment": 40000,
                "recommended_loan": 160000
            }
        """
        available_monthly = monthly_income - monthly_expenses
        max_monthly_payment = (monthly_income * max_payment_ratio) / 100

        # Təxmini property price (30 illik, 12% faizlə)
        # Reverse calculation: əgər aylıq ödəniş bilinərsə, loan amount tap
        # Formula: L = M * ((1 + r)^n - 1) / (r * (1 + r)^n)

        rate = 12.0 / 100 / 12  # Aylıq faiz
        n = 30 * 12  # Ödəniş sayı

        estimated_loan = max_monthly_payment * (
            (math.pow(1 + rate, n) - 1) / (rate * math.pow(1 + rate, n))
        )

        # 20% ilkin ödəniş fərzi ilə
        estimated_property_price = estimated_loan / 0.8
        estimated_down_payment = estimated_property_price * 0.2

        return {
            "monthly_income": round(monthly_income, 2),
            "monthly_expenses": round(monthly_expenses, 2),
            "available_monthly": round(available_monthly, 2),
            "max_monthly_payment": round(max_monthly_payment, 2),
            "max_payment_ratio": max_payment_ratio,
            "recommended_property_price": round(estimated_property_price, 2),
            "recommended_down_payment": round(estimated_down_payment, 2),
            "recommended_loan": round(estimated_loan, 2)
        }


# Test
if __name__ == "__main__":
    # Nümunə: 150000 AZN property, 20% ilkin ödəniş, 30 il
    result = MortgageService.calculate_mortgage(
        property_price=150000,
        down_payment_percent=20,
        term_years=30,
        bank_key="kapital_bank"
    )

    print("Mortgage Hesablaması:")
    print(f"Property qiyməti: {result['property_price']} AZN")
    print(f"İlkin ödəniş: {result['down_payment']} AZN ({result['down_payment_percent']}%)")
    print(f"Kredit məbləği: {result['loan_amount']} AZN")
    print(f"Aylıq ödəniş: {result['monthly_payment']} AZN")
    print(f"Ümumi ödəniş: {result['total_payment']} AZN")
    print(f"Ümumi faiz: {result['total_interest']} AZN")
    print(f"Bank: {result['bank']}")
    print(f"Faiz: {result['rate']}%")
