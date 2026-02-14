"""replace_phone_with_email_otp

Revision ID: b50ed6cf5eb3
Revises: 8a2245c84c53
Create Date: 2026-02-14 23:28:15.581772

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b50ed6cf5eb3'
down_revision: Union[str, Sequence[str], None] = '8a2245c84c53'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema - replace phone_number with email in otp_codes table."""
    # Drop old index
    op.drop_index('ix_otp_codes_phone_number', table_name='otp_codes')

    # Rename column
    op.alter_column('otp_codes', 'phone_number',
                    new_column_name='email',
                    existing_type=sa.String(),
                    existing_nullable=False)

    # Create new index
    op.create_index('ix_otp_codes_email', 'otp_codes', ['email'])


def downgrade() -> None:
    """Downgrade schema - restore phone_number column."""
    # Drop new index
    op.drop_index('ix_otp_codes_email', table_name='otp_codes')

    # Rename column back
    op.alter_column('otp_codes', 'email',
                    new_column_name='phone_number',
                    existing_type=sa.String(),
                    existing_nullable=False)

    # Restore old index
    op.create_index('ix_otp_codes_phone_number', 'otp_codes', ['phone_number'])
