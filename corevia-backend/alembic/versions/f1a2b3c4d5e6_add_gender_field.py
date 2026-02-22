"""add gender field to users

Revision ID: f1a2b3c4d5e6
Revises: d1f2a3b4c5d6
Create Date: 2026-02-21 14:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f1a2b3c4d5e6'
down_revision: Union[str, None] = 'd1f2a3b4c5d6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('gender', sa.String(20), nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'gender')
