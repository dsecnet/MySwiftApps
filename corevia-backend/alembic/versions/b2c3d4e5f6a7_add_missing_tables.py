"""add_missing_tables (daily_surveys, analytics, live_sessions, social, marketplace)

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-02-23 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b2c3d4e5f6a7'
down_revision: Union[str, None] = 'a1b2c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_exists(conn, table_name: str) -> bool:
    result = conn.execute(sa.text(
        "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = :t)"
    ), {"t": table_name})
    return result.scalar()


def _column_exists(conn, table_name: str, column_name: str) -> bool:
    result = conn.execute(sa.text(
        "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = :t AND column_name = :c)"
    ), {"t": table_name, "c": column_name})
    return result.scalar()


def upgrade() -> None:
    conn = op.get_bind()

    # ============================================================
    # 1. daily_surveys
    # ============================================================
    if not _table_exists(conn, 'daily_surveys'):
        op.create_table('daily_surveys',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('date', sa.Date(), nullable=False),
            sa.Column('energy_level', sa.Integer(), nullable=False),
            sa.Column('sleep_hours', sa.Float(), nullable=False),
            sa.Column('sleep_quality', sa.Integer(), nullable=False),
            sa.Column('stress_level', sa.Integer(), nullable=False),
            sa.Column('muscle_soreness', sa.Integer(), nullable=False),
            sa.Column('mood', sa.Integer(), nullable=False),
            sa.Column('water_glasses', sa.Integer(), nullable=False),
            sa.Column('notes', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_daily_surveys_user_id', 'daily_surveys', ['user_id'])
        op.create_index('ix_daily_surveys_date', 'daily_surveys', ['date'])

    # ============================================================
    # 2. Analytics tables: daily_stats, weekly_stats, body_measurements
    # ============================================================
    if not _table_exists(conn, 'daily_stats'):
        op.create_table('daily_stats',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('date', sa.Date(), nullable=False),
            sa.Column('workouts_completed', sa.Integer(), server_default='0'),
            sa.Column('total_workout_minutes', sa.Integer(), server_default='0'),
            sa.Column('calories_burned', sa.Integer(), server_default='0'),
            sa.Column('distance_km', sa.Float(), server_default='0.0'),
            sa.Column('calories_consumed', sa.Integer(), server_default='0'),
            sa.Column('protein_g', sa.Float(), server_default='0.0'),
            sa.Column('carbs_g', sa.Float(), server_default='0.0'),
            sa.Column('fats_g', sa.Float(), server_default='0.0'),
            sa.Column('weight_kg', sa.Float(), nullable=True),
            sa.Column('body_fat_percent', sa.Float(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_daily_stats_user_id', 'daily_stats', ['user_id'])
        op.create_index('ix_daily_stats_date', 'daily_stats', ['date'])

    if not _table_exists(conn, 'weekly_stats'):
        op.create_table('weekly_stats',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('week_start', sa.Date(), nullable=False),
            sa.Column('week_end', sa.Date(), nullable=False),
            sa.Column('workouts_completed', sa.Integer(), server_default='0'),
            sa.Column('total_workout_minutes', sa.Integer(), server_default='0'),
            sa.Column('calories_burned', sa.Integer(), server_default='0'),
            sa.Column('calories_consumed', sa.Integer(), server_default='0'),
            sa.Column('distance_km', sa.Float(), server_default='0.0'),
            sa.Column('avg_daily_calories_burned', sa.Integer(), server_default='0'),
            sa.Column('avg_daily_calories_consumed', sa.Integer(), server_default='0'),
            sa.Column('weight_change_kg', sa.Float(), nullable=True),
            sa.Column('workout_consistency_percent', sa.Integer(), server_default='0'),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_weekly_stats_user_id', 'weekly_stats', ['user_id'])
        op.create_index('ix_weekly_stats_week_start', 'weekly_stats', ['week_start'])

    if not _table_exists(conn, 'body_measurements'):
        op.create_table('body_measurements',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('measured_at', sa.Date(), nullable=False),
            sa.Column('weight_kg', sa.Float(), nullable=False),
            sa.Column('body_fat_percent', sa.Float(), nullable=True),
            sa.Column('muscle_mass_kg', sa.Float(), nullable=True),
            sa.Column('chest_cm', sa.Float(), nullable=True),
            sa.Column('waist_cm', sa.Float(), nullable=True),
            sa.Column('hips_cm', sa.Float(), nullable=True),
            sa.Column('arms_cm', sa.Float(), nullable=True),
            sa.Column('legs_cm', sa.Float(), nullable=True),
            sa.Column('notes', sa.String(500), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_body_measurements_user_id', 'body_measurements', ['user_id'])
        op.create_index('ix_body_measurements_measured_at', 'body_measurements', ['measured_at'])

    # ============================================================
    # 3. Live Session tables
    # ============================================================
    if not _table_exists(conn, 'live_sessions'):
        op.create_table('live_sessions',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('trainer_id', sa.String(), nullable=False),
            sa.Column('title', sa.String(200), nullable=False),
            sa.Column('description', sa.Text(), nullable=True),
            sa.Column('session_type', sa.String(50), nullable=False),
            sa.Column('max_participants', sa.Integer(), server_default='10'),
            sa.Column('difficulty_level', sa.String(20), nullable=True),
            sa.Column('duration_minutes', sa.Integer(), nullable=False),
            sa.Column('scheduled_start', sa.DateTime(), nullable=False),
            sa.Column('scheduled_end', sa.DateTime(), nullable=False),
            sa.Column('actual_start', sa.DateTime(), nullable=True),
            sa.Column('actual_end', sa.DateTime(), nullable=True),
            sa.Column('status', sa.String(20), server_default='scheduled'),
            sa.Column('is_public', sa.Boolean(), server_default=sa.text('true')),
            sa.Column('is_paid', sa.Boolean(), server_default=sa.text('false')),
            sa.Column('price', sa.Float(), server_default='0.0'),
            sa.Column('currency', sa.String(3), server_default='USD'),
            sa.Column('workout_plan', sa.JSON(), nullable=True),
            sa.Column('session_recording_url', sa.String(500), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['trainer_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    if not _table_exists(conn, 'session_participants'):
        op.create_table('session_participants',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('session_id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('status', sa.String(20), server_default='registered'),
            sa.Column('joined_at', sa.DateTime(), nullable=True),
            sa.Column('left_at', sa.DateTime(), nullable=True),
            sa.Column('completed_exercises', sa.Integer(), server_default='0'),
            sa.Column('total_reps', sa.Integer(), server_default='0'),
            sa.Column('calories_burned', sa.Float(), server_default='0.0'),
            sa.Column('avg_form_score', sa.Float(), nullable=True),
            sa.Column('total_corrections', sa.Integer(), server_default='0'),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['session_id'], ['live_sessions.id'], ),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    if not _table_exists(conn, 'session_exercises'):
        op.create_table('session_exercises',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('session_id', sa.String(), nullable=False),
            sa.Column('exercise_name', sa.String(200), nullable=False),
            sa.Column('exercise_type', sa.String(50), nullable=True),
            sa.Column('target_reps', sa.Integer(), nullable=True),
            sa.Column('target_sets', sa.Integer(), nullable=True),
            sa.Column('target_duration_seconds', sa.Integer(), nullable=True),
            sa.Column('rest_duration_seconds', sa.Integer(), server_default='60'),
            sa.Column('order_index', sa.Integer(), nullable=False),
            sa.Column('instructions', sa.Text(), nullable=True),
            sa.Column('demo_video_url', sa.String(500), nullable=True),
            sa.Column('pose_detection_enabled', sa.Boolean(), server_default=sa.text('true')),
            sa.Column('key_points', sa.JSON(), nullable=True),
            sa.Column('form_criteria', sa.JSON(), nullable=True),
            sa.Column('started_at', sa.DateTime(), nullable=True),
            sa.Column('completed_at', sa.DateTime(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['session_id'], ['live_sessions.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    if not _table_exists(conn, 'participant_exercises'):
        op.create_table('participant_exercises',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('participant_id', sa.String(), nullable=False),
            sa.Column('exercise_id', sa.String(), nullable=False),
            sa.Column('completed_reps', sa.Integer(), server_default='0'),
            sa.Column('completed_sets', sa.Integer(), server_default='0'),
            sa.Column('completed_duration_seconds', sa.Integer(), server_default='0'),
            sa.Column('is_completed', sa.Boolean(), server_default=sa.text('false')),
            sa.Column('form_scores', sa.JSON(), nullable=True),
            sa.Column('avg_form_score', sa.Float(), nullable=True),
            sa.Column('corrections_received', sa.Integer(), server_default='0'),
            sa.Column('started_at', sa.DateTime(), nullable=True),
            sa.Column('completed_at', sa.DateTime(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['participant_id'], ['session_participants.id'], ),
            sa.ForeignKeyConstraint(['exercise_id'], ['session_exercises.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    if not _table_exists(conn, 'session_stats'):
        op.create_table('session_stats',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('session_id', sa.String(), nullable=False, unique=True),
            sa.Column('total_registered', sa.Integer(), server_default='0'),
            sa.Column('total_joined', sa.Integer(), server_default='0'),
            sa.Column('total_completed', sa.Integer(), server_default='0'),
            sa.Column('peak_concurrent', sa.Integer(), server_default='0'),
            sa.Column('avg_completion_rate', sa.Float(), server_default='0.0'),
            sa.Column('avg_form_score', sa.Float(), server_default='0.0'),
            sa.Column('total_corrections', sa.Integer(), server_default='0'),
            sa.Column('total_reps', sa.Integer(), server_default='0'),
            sa.Column('total_calories_burned', sa.Float(), server_default='0.0'),
            sa.Column('avg_duration_minutes', sa.Float(), server_default='0.0'),
            sa.Column('avg_rating', sa.Float(), nullable=True),
            sa.Column('total_ratings', sa.Integer(), server_default='0'),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['session_id'], ['live_sessions.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    if not _table_exists(conn, 'pose_detection_logs'):
        op.create_table('pose_detection_logs',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('participant_id', sa.String(), nullable=False),
            sa.Column('exercise_id', sa.String(), nullable=False),
            sa.Column('timestamp', sa.DateTime(), nullable=False),
            sa.Column('rep_number', sa.Integer(), nullable=True),
            sa.Column('keypoints', sa.JSON(), nullable=True),
            sa.Column('angles', sa.JSON(), nullable=True),
            sa.Column('form_score', sa.Float(), nullable=True),
            sa.Column('correction_type', sa.String(50), nullable=True),
            sa.Column('correction_message', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['participant_id'], ['session_participants.id'], ),
            sa.ForeignKeyConstraint(['exercise_id'], ['session_exercises.id'], ),
            sa.PrimaryKeyConstraint('id')
        )

    # ============================================================
    # 4. Social tables (were dropped in migration 8a2245c84c53, re-create)
    # ============================================================
    if not _table_exists(conn, 'posts'):
        op.create_table('posts',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('post_type', sa.String(50), nullable=False),
            sa.Column('content', sa.Text(), nullable=True),
            sa.Column('image_url', sa.String(500), nullable=True),
            sa.Column('workout_id', sa.String(), nullable=True),
            sa.Column('food_entry_id', sa.String(), nullable=True),
            sa.Column('likes_count', sa.Integer(), server_default='0'),
            sa.Column('comments_count', sa.Integer(), server_default='0'),
            sa.Column('is_public', sa.Boolean(), server_default=sa.text('true')),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.ForeignKeyConstraint(['workout_id'], ['workouts.id'], ),
            sa.ForeignKeyConstraint(['food_entry_id'], ['food_entries.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_posts_user_id', 'posts', ['user_id'])
        op.create_index('ix_posts_created_at', 'posts', ['created_at'])

    if not _table_exists(conn, 'post_likes'):
        op.create_table('post_likes',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('post_id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['post_id'], ['posts.id'], ),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_post_likes_post_id', 'post_likes', ['post_id'])
        op.create_index('ix_post_likes_user_id', 'post_likes', ['user_id'])

    if not _table_exists(conn, 'post_comments'):
        op.create_table('post_comments',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('post_id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('content', sa.Text(), nullable=False),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['post_id'], ['posts.id'], ),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_post_comments_post_id', 'post_comments', ['post_id'])
        op.create_index('ix_post_comments_user_id', 'post_comments', ['user_id'])
        op.create_index('ix_post_comments_created_at', 'post_comments', ['created_at'])

    if not _table_exists(conn, 'follows'):
        op.create_table('follows',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('follower_id', sa.String(), nullable=False),
            sa.Column('following_id', sa.String(), nullable=False),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['follower_id'], ['users.id'], ),
            sa.ForeignKeyConstraint(['following_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_follows_follower_id', 'follows', ['follower_id'])
        op.create_index('ix_follows_following_id', 'follows', ['following_id'])

    if not _table_exists(conn, 'achievements'):
        op.create_table('achievements',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('user_id', sa.String(), nullable=False),
            sa.Column('achievement_type', sa.String(50), nullable=False),
            sa.Column('title', sa.String(200), nullable=False),
            sa.Column('description', sa.Text(), nullable=True),
            sa.Column('icon_url', sa.String(500), nullable=True),
            sa.Column('earned_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_achievements_user_id', 'achievements', ['user_id'])

    # ============================================================
    # 5. Marketplace tables (were dropped in migration 8a2245c84c53, re-create)
    # ============================================================
    if not _table_exists(conn, 'marketplace_products'):
        op.create_table('marketplace_products',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('seller_id', sa.String(), nullable=False),
            sa.Column('product_type', sa.String(50), nullable=False),
            sa.Column('title', sa.String(200), nullable=False),
            sa.Column('description', sa.Text(), nullable=False),
            sa.Column('price', sa.Float(), nullable=False),
            sa.Column('currency', sa.String(10), server_default='AZN'),
            sa.Column('cover_image_url', sa.String(500), nullable=True),
            sa.Column('preview_video_url', sa.String(500), nullable=True),
            sa.Column('content_data', sa.Text(), nullable=True),
            sa.Column('sales_count', sa.Integer(), server_default='0'),
            sa.Column('rating', sa.Float(), nullable=True),
            sa.Column('reviews_count', sa.Integer(), server_default='0'),
            sa.Column('is_published', sa.Boolean(), server_default=sa.text('false')),
            sa.Column('is_featured', sa.Boolean(), server_default=sa.text('false')),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.Column('updated_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['seller_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_marketplace_products_seller_id', 'marketplace_products', ['seller_id'])
        op.create_index('ix_marketplace_products_created_at', 'marketplace_products', ['created_at'])

    if not _table_exists(conn, 'product_purchases'):
        op.create_table('product_purchases',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('product_id', sa.String(), nullable=False),
            sa.Column('buyer_id', sa.String(), nullable=False),
            sa.Column('amount_paid', sa.Float(), nullable=False),
            sa.Column('currency', sa.String(10), server_default='AZN'),
            sa.Column('transaction_id', sa.String(200), nullable=True, unique=True),
            sa.Column('receipt_data', sa.Text(), nullable=True),
            sa.Column('purchased_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['product_id'], ['marketplace_products.id'], ),
            sa.ForeignKeyConstraint(['buyer_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_product_purchases_product_id', 'product_purchases', ['product_id'])
        op.create_index('ix_product_purchases_buyer_id', 'product_purchases', ['buyer_id'])
        op.create_index('ix_product_purchases_purchased_at', 'product_purchases', ['purchased_at'])

    if not _table_exists(conn, 'product_reviews'):
        op.create_table('product_reviews',
            sa.Column('id', sa.String(), nullable=False),
            sa.Column('product_id', sa.String(), nullable=False),
            sa.Column('buyer_id', sa.String(), nullable=False),
            sa.Column('rating', sa.Integer(), nullable=False),
            sa.Column('comment', sa.Text(), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['product_id'], ['marketplace_products.id'], ),
            sa.ForeignKeyConstraint(['buyer_id'], ['users.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index('ix_product_reviews_product_id', 'product_reviews', ['product_id'])
        op.create_index('ix_product_reviews_buyer_id', 'product_reviews', ['buyer_id'])

    # ============================================================
    # 6. Add ai_analyzed / ai_confidence columns to food_entries (if not exist)
    # ============================================================
    if not _column_exists(conn, 'food_entries', 'ai_analyzed'):
        op.add_column('food_entries', sa.Column('ai_analyzed', sa.Boolean(), server_default=sa.text('false')))

    if not _column_exists(conn, 'food_entries', 'ai_confidence'):
        op.add_column('food_entries', sa.Column('ai_confidence', sa.Float(), nullable=True))


def downgrade() -> None:
    # Marketplace
    op.drop_index('ix_product_reviews_buyer_id', table_name='product_reviews')
    op.drop_index('ix_product_reviews_product_id', table_name='product_reviews')
    op.drop_table('product_reviews')
    op.drop_index('ix_product_purchases_purchased_at', table_name='product_purchases')
    op.drop_index('ix_product_purchases_buyer_id', table_name='product_purchases')
    op.drop_index('ix_product_purchases_product_id', table_name='product_purchases')
    op.drop_table('product_purchases')
    op.drop_index('ix_marketplace_products_created_at', table_name='marketplace_products')
    op.drop_index('ix_marketplace_products_seller_id', table_name='marketplace_products')
    op.drop_table('marketplace_products')

    # Social
    op.drop_index('ix_achievements_user_id', table_name='achievements')
    op.drop_table('achievements')
    op.drop_index('ix_follows_following_id', table_name='follows')
    op.drop_index('ix_follows_follower_id', table_name='follows')
    op.drop_table('follows')
    op.drop_index('ix_post_comments_created_at', table_name='post_comments')
    op.drop_index('ix_post_comments_user_id', table_name='post_comments')
    op.drop_index('ix_post_comments_post_id', table_name='post_comments')
    op.drop_table('post_comments')
    op.drop_index('ix_post_likes_user_id', table_name='post_likes')
    op.drop_index('ix_post_likes_post_id', table_name='post_likes')
    op.drop_table('post_likes')
    op.drop_index('ix_posts_created_at', table_name='posts')
    op.drop_index('ix_posts_user_id', table_name='posts')
    op.drop_table('posts')

    # Live Sessions
    op.drop_table('pose_detection_logs')
    op.drop_table('session_stats')
    op.drop_table('participant_exercises')
    op.drop_table('session_exercises')
    op.drop_table('session_participants')
    op.drop_table('live_sessions')

    # Analytics
    op.drop_index('ix_body_measurements_measured_at', table_name='body_measurements')
    op.drop_index('ix_body_measurements_user_id', table_name='body_measurements')
    op.drop_table('body_measurements')
    op.drop_index('ix_weekly_stats_week_start', table_name='weekly_stats')
    op.drop_index('ix_weekly_stats_user_id', table_name='weekly_stats')
    op.drop_table('weekly_stats')
    op.drop_index('ix_daily_stats_date', table_name='daily_stats')
    op.drop_index('ix_daily_stats_user_id', table_name='daily_stats')
    op.drop_table('daily_stats')

    # Daily Surveys
    op.drop_index('ix_daily_surveys_date', table_name='daily_surveys')
    op.drop_index('ix_daily_surveys_user_id', table_name='daily_surveys')
    op.drop_table('daily_surveys')

    # Food entries AI columns
    op.drop_column('food_entries', 'ai_confidence')
    op.drop_column('food_entries', 'ai_analyzed')
