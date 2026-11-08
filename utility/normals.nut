/**
	Functions below by Enviolinador:

 * Attempts to project a triangle onto a surface in front of a point and in a direction
 * to compute the normal of the plane in that surface
 */
::GetApproxPlaneNormal <- function(orig, vec, delta=0.01, drawTrianglePlane=false)
{
    // Compute the direction vector
    local length = vec.Length();
    local dir = vnorm(vec);
    local yaw = atan2(dir.x, dir.z);
    local pitch = atan2(dir.y, sqrt((dir.x * dir.x) + (dir.z * dir.z)));

    // Compute R direction
    local xR = sin(yaw+delta)*cos(pitch+delta);
    local yR = sin(pitch+delta);
    local zR = cos(yaw+delta)*cos(pitch+delta);
    local endR = Vector(xR, yR, zR);
    local vecR = vscale(vnorm(endR), length);

    // Compute L direction
    local xL = sin(yaw-delta)*cos(pitch+delta);
    local yL = sin(pitch+delta);
    local zL = cos(yaw-delta)*cos(pitch+delta);
    local endL = Vector(xL, yL, zL);
    local vecL = vscale(vnorm(endL), length);

    // Find end points distance
    local distA = TraceLine(orig, vadd(orig, vec), null);
    local distB = TraceLine(orig, vadd(orig, vecR), null);
    local distC = TraceLine(orig, vadd(orig, vecL), null);

    // Compute the 3 triangle verts
    local vertA = vadd(orig, vscale(vec, distA));
    local vertB = vadd(orig, vscale(vecR, distB));
    local vertC = vadd(orig, vscale(vecL, distC));

    // Return a null vector if any of the traces hit nothing
    if(distA == 1 && distB == 1 && distC == 1)
        return Vector(0.0, 0.0, 0.0);

    // Draw the triangle used to compute the normal, if desired
    if(drawTrianglePlane)
    {
        DebugDrawLine(vertA, vertB, 255, 0, 0, false, 5);
        DebugDrawLine(vertB, vertC, 0, 255, 0, false, 5);
        DebugDrawLine(vertC, vertA, 0, 0, 255, false, 5);
    }

    // Compute the two planar vectors
    local t1 = vsub(vertB, vertA);
    local t2 = vsub(vertB, vertC);
    local norm = vcross(t1, t2);

    // Return if the normal is the null vector (either t1, t2 or both are null)
    if(vnull(norm))
        return norm;

    // Correct the normal if we're going in the same direction as the original vector
    norm = vnorm(norm);
    if(veqd(norm, dir))
        norm = vinv(norm);
    return norm;
}

/**
 * Compute the negated/inverse direction vector
 */
function vinv(v)
{
    return Vector(-v.x, -v.y, -v.z);
}

/**
 * Add two vectors
 */
function vadd(v1, v2)
{
    return Vector(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

/**
 * Subtract two vectors
 */
function vsub(v1, v2)
{
    return Vector(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}

/**
 * Multiply all vector components by a scalar
 */
function vscale(v, s)
{
    return Vector(v.x * s, v.y * s, v.z * s);
}

/**
 * Cross product of two vectors, wrapping v1.Cross(v2)
 */
function vcross(v1, v2)
{
    return v1.Cross(v2);
}

/**
 * Divide all components of a vector by a scalar
 */
function vdiv(v, d)
{
    return Vector(v.x / d, v.y / d, v.z / d);
}

/**
 * Generate a '2D' vector with z = 0
 */
function v2D(v)
{
	return Vector(v.x, v.y, 0.0);
}

/**
 * Get the 2D angle (from top persp.) of a vector
 */
function v2Dang(v)
{
    return 180.0 * atan2(v.y, v.x) / PI;
}

/**
 * Normalization of a vector, equivalent for v.norm()
 */
function vnorm(v)
{
	return vdiv(v, v.Length())
}

/**
 * Dor product of two vectors
 */
function vdot(v1, v2)
{
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

/**
 * Cap vector length
 */
function vcap(v, limit)
{
    if(v.Length() > limit)
    	return vscale(v.norm(), limit);
    else
    	return v;
}

/**
 * Angle between two vectors
 */
function vang(v1, v2)
{
    local dot = vdot(v1, v2);
    local l1 = v1.Length();
    local l2 = v2.Length();
    return acos(dot/(l1*l2));
}

/**
 * Vector equality
 */
function veq(v1, v2)
{
    return v1.x == v2.x && 
           v1.y == v2.y &&
           v1.z == v2.z; 
}

/**
 * Vector equality with a delta
 */
function veqd(v1, v2, d=0.001){
    return abs(v1.x - v2.x) < d && 
           abs(v1.y - v2.y) < d &&
           abs(v1.z - v2.z) < d; 
}

/**
 * Check if a vector is the null vector
 */
function vnull(v)
{
    return v.x == 0 && v.y == 0 && v.z == 0;
}

/**
 * Compute the reflection of a vector v with respect to the normal n
 */
function vrefl(v, n)
{
    local nn = vnorm(n);
    local dot = vdot(v, nn);
    local term = vscale(n, 2*dot)
    return vsub(v, term); 
}

/**
 * Computes the plane to point distance with a plane
 * defined as a point and its normalized normal vector.
 */
function GetPointToPlaneDistance(plp, pln, target)
{
    return vdot(target, pln) - vdot(plp, pln);
}