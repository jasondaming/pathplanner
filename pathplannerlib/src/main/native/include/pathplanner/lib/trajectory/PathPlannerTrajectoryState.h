#pragma once

#include <units/velocity.h>
#include <units/length.h>
#include <units/time.h>
#include <units/current.h>
#include <frc/kinematics/ChassisSpeeds.h>
#include <frc/geometry/Pose2d.h>
#include <frc/geometry/Translation2d.h>
#include <frc/geometry/Rotation2d.h>
#include <vector>
#include "pathplanner/lib/trajectory/SwerveModuleTrajectoryState.h"
#include "pathplanner/lib/path/PathConstraints.h"
#include "pathplanner/lib/util/GeometryUtil.h"

namespace pathplanner {
class PathPlannerTrajectoryState {
public:
	units::second_t time = 0_s;
	frc::ChassisSpeeds fieldSpeeds;
	frc::Pose2d pose;
	units::meters_per_second_t linearVelocity = 0_mps;
	std::vector<units::ampere_t> driveMotorTorqueCurrent;

	frc::Rotation2d heading;
	units::meter_t deltaPos = 0_m;
	frc::Rotation2d deltaRot;
	std::vector<SwerveModuleTrajectoryState> moduleStates;
	PathConstraints constraints;
	double waypointRelativePos = 0.0;

	PathPlannerTrajectoryState() : constraints(0_mps, 0_mps_sq, 0_rad_per_s,
			0_rad_per_s_sq) {
	}

	/**
	 * Interpolate between this state and the given state
	 *
	 * @param endVal State to interpolate with
	 * @param t Interpolation factor (0.0-1.0)
	 * @return Interpolated state
	 */
	PathPlannerTrajectoryState interpolate(
			const PathPlannerTrajectoryState &endVal, const double t) const;

	/**
	 * Get the state reversed, used for following a trajectory reversed with a differential drivetrain
	 *
	 * @return The reversed state
	 */
	PathPlannerTrajectoryState reverse() const;

	/**
	 * Flip this trajectory state for the other side of the field, maintaining a blue alliance origin
	 *
	 * @return This trajectory state flipped to the other side of the field
	 */
	PathPlannerTrajectoryState flip() const;
};
}