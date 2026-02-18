"""add_plan_completion_fields

Revision ID: d1f2a3b4c5d6
Revises: b50ed6cf5eb3
Create Date: 2026-02-18 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd1f2a3b4c5d6'
down_revision: Union[str, Sequence[str], None] = 'b50ed6cf5eb3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add is_completed and completed_at to training_plans and meal_plans."""
    op.add_column('training_plans', sa.Column('is_completed', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('training_plans', sa.Column('completed_at', sa.DateTime(), nullable=True))

    op.add_column('meal_plans', sa.Column('is_completed', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('meal_plans', sa.Column('completed_at', sa.DateTime(), nullable=True))


def downgrade() -> None:
    """Remove is_completed and completed_at from training_plans and meal_plans."""
    op.drop_column('meal_plans', 'completed_at')
    op.drop_column('meal_plans', 'is_completed')

    op.drop_column('training_plans', 'completed_at')
    op.drop_column('training_plans', 'is_completed')
