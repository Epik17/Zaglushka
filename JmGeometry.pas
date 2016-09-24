{******************************************************************************}
{                                                                              }
{ JmGEO.pas for Jedi Math Alpha 1.03a                                          }
{ Project JEDI Math  http://sourceforge.net/projects/jedimath/                 }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.1 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{ or see the file MPL-1.1.txt included in this package.                        }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ The Original Code is FastGEO.pas.                                            }
{                                                                              }
{ Origonal comment:                                                            }
{                                                                              }
{                             FASTGEO                                          }
{                                                                              }
{                2D/3D Computational Geometry Algorithms                       }
{                         Release Version 5.0.1                                }
{                                                                              }
{ Author: Arash Partow 1997-2004                                               }
{ Copyright notice:                                                            }
{                                                                              }
{ Free use of the FastGEO computational geometry library is permitted          }
{ under the guidelines and in accordance with the most current version         }
{ of the Common Public License.                                                }
{ http://www.opensource.org/licenses/cpl.php                                   }
{                                                                              }
{ New comment:                                                                 }
{                                                                              }
{ This version of FASTGEO was donated to JEDI Math and is now subject          }
{ to the Mozilla Public Liscence as mentioned above.                           }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ Unit owner: Arash Partow                                                     }
{ Last modified:                                                               }
{      20.02.2005 by Ralph K. Muench (ralphkmuench@users.sourceforge.net)      }
{      for the Jedi Math Alpha 1.03a release                                   }
{                                                                              }
{******************************************************************************}

Unit JmGeometry;

Interface

uses JmTypes;

Const VersionInformation = 'FastGEO Version 5.0.1';
Const AuthorInformation  = 'Arash Partow (1997-2004)';
Const EpochInformation   = 'Delta-Zulu';


{
   Note:
    1. Some of the algorithms have been implemented using
       "laydistance" or other methods rather than simply using sqrt.
       It turns out a really fast sqrt approximation for integers
       requires at "LEAST" 24 multiplications. So imagine how many
       it takes for a real sqrt for TJmFloats, regardless of the fact
       that it is implemented in hardware it is just to costly for
       algorithms that are used repeatedly i.e.: within tight loops etc...

   2. Regression testing of the algorithms will be in the form of obtaining
      an initial result using a particular algorithm, then applying a transformation
      to which the algorithm itself is invariant. Then reapplying the algorithm.
      If the initial result and current results are equivelent it means the
      algorithm is to a certain degree "bug-free"

  Computational Costs
  1.) 2D Orientation :   5 (-), 2 (*)
  2.) 3D Orientation :  12 (-), 9 (*)
  3.) 2D Collinear   :   6 (-), 2 (*)
  4.) 3D Collinear   :  10 (-), 2 (+) 9 (*)

}


(****************************************************************************)
(********************[ Basic Geometric Structure Types ]*********************)
(****************************************************************************)

(**************[  Vertex Type   ]***************)
Type TPoint2D       = Record x,y:TJmFloat; End;
Type TPoint2DPtr    = ^TPoint2D;


(**************[ 3D Vertex Type ]***************)
Type TPoint3D       = Record x,y,z:TJmFloat; End;
Type TPoint3DPtr    = ^TPoint3D;


(**************[  Quadix Type   ]***************)
Type TQuadix2D      = Array[1..4] Of TPoint2D;
Type TQuadix2DPtr   = ^TQuadix2D;

Type TQuadix3D      = Array[1..4] Of TPoint3D;
Type TQuadix3DPtr   = ^TQuadix3D;


(**************[ Rectangle Type ]***************)
Type TRectangle     = Array[1..2] Of TPoint2D;
Type TRectanglePtr  = ^TRectangle;


(**************[ Triangle Type  ]***************)
Type TTriangle2D    = Array[1..3] Of TPoint2D;
Type TTriangle2DPtr = ^TTRiangle2D;

Type TTriangle3D    = Array[1..3] Of TPoint3D;
Type TTriangle3DPtr = ^TTriangle3D;


(**************[  Segment Type  ]***************)
Type TLine2D        = Array[1..2] Of TPoint2D;
Type TLine2DPtr     = ^TLine2D;

Type TLine3D        = Array[1..2] Of TPoint3D;
Type TLine3DPtr     = ^TLine3D;

Type TSegment2D     = Array[1..2] Of TPoint2D;
Type TSegment2DPtr  = ^TSegment2D;

Type TSegment3D     = Array[1..2] Of TPoint3D;
Type TSegment3DPtr  = ^TSegment3D;


(**************[  Circle Type   ]***************)
Type TCircle        = Record x,y,Radius:TJmFloat; End;
Type TCirclePtr     = ^TCircle;


(**************[  Sphere Type   ]***************)
Type TSphere        = Record x,y,z,Radius:TJmFloat; End;
Type TSpherePtr     = ^TSphere;


(**************[ 2D Vector Type ]***************)
Type TVector2D      = Record x,y:TJmFloat; End;
Type TVector2DPtr   = ^TVector2D;


(**************[ 3D Vector Type ]***************)
Type TVector3D      = Record x,y,z:TJmFloat; End;
Type TVector3DPtr   = ^TVector3D;


(**********[ Polygon Vertex Type  ]************)
Type TPolygon2D     = Array of TPoint2D;
Type TPolygonPtr    = ^TPolygon2D;

Type TPolygon3D     = Array of TPoint3D;
Type TPolygon3DPtr  = ^TPolygon3D;

Type TPolyhedron    = Array Of TPolygon3D;
Type TPolyhedronPtr = ^TPolyhedron;


(**************[ Plane Type ]******************)

Type TPlane2D       = Record a,b,c:TJmFloat; End;
Type TPlane2DPtr    = ^TPlane2D;

Type TPlane3D       = Record a,b,c,d:TJmFloat; End;
Type TPlane3DPtr    = ^TPlane3D;

Type TInclusion    = (Fully,Partially,Outside,IUnknown);
Type TTriangleType = (Equilateral,Isosceles,Right,Scalene,Obtuse,TUnknown);



(********[ Universal Geometric Variable ]********)

Type TGeometricObjectTypes = (
                              GOPoint2D,
                              GOPoint3D,
                              GOLine2D,
                              GOLine3D,
                              GOSegment2D,
                              GOSegment3D,
                              GOQuadix2D,
                              GOQuadix3D,
                              GOTriangle2D,
                              GOTriangle3D,
                              GORectangle,
                              GOCircle,
                              GOSphere,
                              GOPolygon2D,
                              GOPolygon3D,
                              GOPolyhedron
                             );


Type TGeometricObject = Record
       Case TGeometricObjectTypes Of
        GOPoint2D    : (Point2D:TPoint2D);
        GOPoint3D    : (Point3D:TPoint3D);
        GOLine2D     : (Line2D:TLine2D);
        GOLine3D     : (Line3D:TLine3D);
        GOSegment2D  : (Segment2D:TSegment2D);
        GOSegment3D  : (Segment3D:TSegment3D);
        GOQuadix2D   : (Quadix2D:TQuadix2D);
        GOQuadix3D   : (Quadix3D:TQuadix3D);
        GOTriangle2D : (Triangle2D:TTriangle2D);
        GOTriangle3D : (Triangle3D:TTriangle3D);
        GORectangle  : (Rectangle:TRectangle);
        GOCircle     : (Circle:TCircle);
        GOSphere     : (Sphere:TSphere);
        GOPolygon2D  : (Polygon:TPolygonPtr);
        GOPolygon3D  : (Polygon3D:TPolygon3DPtr);
        GOPolyhedron : (Polyhedron:TPolyhedronPtr);
     End;




Const
(************[ Orientation Constants ]**********)
     RightHand         = -1;
     LeftHand          = +1;
     Clockwise         = -1;
     CounterClockwise  = +1;



Function Orientation(x1,y1,x2,y2,Px,Py:TJmFloat):Integer;                             Overload;
Function Orientation(x1,y1,z1,x2,y2,z2,x3,y3,z3,Px,Py,Pz:TJmFloat):Integer;           Overload;

Function Orientation(Pnt1,Pnt2:TPoint2D; Px,Py:TJmFloat):Integer;                     Overload;
Function Orientation(Pnt1,Pnt2,Pnt3:TPoint2D):Integer;                              Overload;
Function Orientation(Ln:TLine2D; Pnt:TPoint2D):Integer;                             Overload;
Function Orientation(Seg:TSegment2D; Pnt:TPoint2D):Integer;                         Overload;

Function Orientation(Pnt1,Pnt2,Pnt3:TPoint3D; Px,Py,Pz:TJmFloat):Integer;             Overload;
Function Orientation(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):Integer;                         Overload;
Function Orientation(Tri:TTriangle3D; Pnt:TPoint3D):Integer;                        Overload;

Function Signed(x1,y1,x2,y2,Px,Py:TJmFloat):TJmFloat;                                   Overload;
Function Signed(x1,y1,z1,x2,y2,z2,x3,y3,z3,Px,Py,Pz:TJmFloat):TJmFloat;                 Overload;

Function Signed(Pnt1,Pnt2:TPoint2D; Px,Py:TJmFloat):TJmFloat;                           Overload;
Function Signed(Pnt1,Pnt2,Pnt3:TPoint2D):TJmFloat;                                    Overload;
Function Signed(Ln:TLine2D; Pnt:TPoint2D):TJmFloat;                                   Overload;
Function Signed(Seg:TSegment2D; Pnt:TPoint2D):TJmFloat;                               Overload;

Function Signed(Pnt1,Pnt2,Pnt3:TPoint3D; Px,Py,Pz:TJmFloat):TJmFloat;                   Overload;
Function Signed(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):TJmFloat;                               Overload;
Function Signed(Tri:TTriangle3D; Pnt:TPoint3D):TJmFloat;                              Overload;

Function Collinear(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                               Overload;
Function Collinear(PntA,PntB,PntC:TPoint2D):Boolean;                                Overload;
Function Collinear(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;                      Overload;
Function Collinear(PntA,PntB,PntC:TPoint3D):Boolean;                                Overload;

Function IsPntCollinear(x1,y1,x2,y2,Px,Py:TJmFloat):Boolean;                          Overload;
Function IsPntCollinear(PntA,PntB,PntC:TPoint2D):Boolean;                           Overload;
Function IsPntCollinear(Line:TLine2D; PntC:TPoint2D):Boolean;                       Overload;
Function IsPntCollinear(x1,y1,z1,x2,y2,z2,Px,Py,Pz:TJmFloat):Boolean;                 Overload;
Function IsPntCollinear(PntA,PntB,PntC:TPoint3D):Boolean;                           Overload;
Function IsPntCollinear(Line:TLine3D; PntC:TPoint3D):Boolean;                       Overload;

Function IsOnRightSide(x,y:TJmFloat; Ln:TLine2D):Boolean;                             Overload;
Function IsOnRightSide(Pnt:TPoint2D; Ln:TLine2D):Boolean;                           Overload;

Function IsOnLeftSide(x,y:TJmFloat; Ln:TLine2D):Boolean;                              Overload;
Function IsOnLeftSide(Pnt:TPoint2D; Ln:TLine2D):Boolean;                            Overload;

Function Intersect(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;                         Overload;
Function Intersect(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):Boolean;                           Overload;
Function Intersect(Seg1,Seg2:TSegment2D):Boolean;                                   Overload;

Function Intersect(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean;             Overload;
Function Intersect(P1,P2,P3,P4:TPoint3D):Boolean;                                   Overload;
Function Intersect(Seg1,Seg2:TSegment3D):Boolean;                                   Overload;

Function Intersect(Seg:TSegment2D; Rec:TRectangle):Boolean;                         Overload;
Function Intersect(Seg:TSegment2D; Tri:TTriangle2D):Boolean;                        Overload;
Function Intersect(Seg:TSegment2D; Quad:TQuadix2D):Boolean;                         Overload;
Function Intersect(Seg:TSegment2D; Cir:TCircle):Boolean;                            Overload;
Function Intersect(Seg:TSegment3D; Sphere:TSphere):Boolean;                         Overload;
Function Intersect(Cir1,Cir2:TCircle):Boolean;                                      Overload;

Procedure IntersectPoint(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat; Var Nx,Ny:TJmFloat);         Overload;
Procedure IntersectPoint(P1,P2,P3,P4:TPoint2D; Var Nx,Ny:TJmFloat);                   Overload;
Function  IntersectPoint(P1,P2,P3,P4:TPoint2D):TPoint2D;                            Overload;
Function  IntersectPoint(Seg1,Seg2:TSegment2D):TPoint2D;                            Overload;
Procedure IntersectPoint(Cir1,Cir2:TCircle; Var Pnt1,Pnt2:TPoint2D);                Overload;

Function VertexAngle(x1,y1,x2,y2,x3,y3:TJmFloat):TJmFloat;                              Overload;
Function VertexAngle(Pnt1,Pnt2,Pnt3:TPoint2D):TJmFloat;                               Overload;
Function VertexAngle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TJmFloat;                     Overload;
Function VertexAngle(Pnt1,Pnt2,Pnt3:TPoint3D):TJmFloat;                               Overload;

Function SegmentIntersectAngle(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):TJmFloat;                Overload;
Function SegmentIntersectAngle(Seg1,Seg2:TSegment2D):TJmFloat;                        Overload;
Function SegmentIntersectAngle(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):TJmFloat;                Overload;
Function SegmentIntersectAngle(Seg1,Seg2:TSegment3D):TJmFloat;                        Overload;

Function InPortal(P:TPoint2D):Boolean;                                              Overload;
Function InPortal(P:TPoint3D):Boolean;                                              Overload;

Function HighestPoint(Polygon: TPolygon2D):TPoint2D;                                Overload;
Function HighestPoint(Tri:TTriangle2D):TPoint2D;                                    Overload;
Function HighestPoint(Tri:TTriangle3D):TPoint3D;                                    Overload;
Function HighestPoint(Quadix:TQuadix2D):TPoint2D;                                   Overload;
Function HighestPoint(Quadix:TQuadix3D):TPoint3D;                                   Overload;

Function LowestPoint(Polygon: TPolygon2D):TPoint2D;                                 Overload;
Function LowestPoint(Tri:TTriangle2D):TPoint2D;                                     Overload;
Function LowestPoint(Tri:TTriangle3D):TPoint3D;                                     Overload;
Function LowestPoint(Quadix:TQuadix2D):TPoint2D;                                    Overload;
Function LowestPoint(Quadix:TQuadix3D):TPoint3D;                                    Overload;

Function Coincident(Pnt1,Pnt2:TPoint2D):Boolean;                                    Overload;
Function Coincident(Pnt1,Pnt2:TPoint3D):Boolean;                                    Overload;
Function Coincident(Seg1,Seg2:TSegment2D):Boolean;                                  Overload;
Function Coincident(Seg1,Seg2:TSegment3D):Boolean;                                  Overload;
Function Coincident(Tri1,Tri2:TTriangle2D):Boolean;                                 Overload;
Function Coincident(Tri1,Tri2:TTriangle3D):Boolean;                                 Overload;
Function Coincident(Rect1,Rect2:TRectangle):Boolean;                                Overload;
Function Coincident(Quad1,Quad2:TQuadix2D):Boolean;                                 Overload;
Function Coincident(Quad1,Quad2:TQuadix3D):Boolean;                                 Overload;
Function Coincident(Cir1,Cir2:TCircle):Boolean;                                     Overload;
Function Coincident(Sphr1,Sphr2:TSphere):Boolean;                                   Overload;

Procedure PerpendicularPntToSegment(x1,y1,x2,y2,Px,Py:TJmFloat; Var Nx,Ny:TJmFloat);    Overload;
Function PerpendicularPntToSegment(Seg:TSegment2D; Pnt:TPoint2D):TPoint2D;          Overload;
Function PntToSegmentDistance(Px,Py,x1,y1,x2,y2:TJmFloat):TJmFloat;                     Overload;
Function PntToSegmentDistance(Pnt:TPoint2D; Seg:TSegment2D):TJmFloat;                 Overload;

Function SegmentsParallel(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;                  Overload;
Function SegmentsParallel(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):Boolean;                    Overload;
Function SegmentsParallel(Seg1,Seg2:TSegment2D):Boolean;                            Overload;

Function SegmentsParallel(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean;      Overload;
Function SegmentsParallel(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):Boolean;                    Overload;
Function SegmentsParallel(Seg1,Seg2:TSegment3D):Boolean;                            Overload;

Function SegmentsPerpendicular(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;             Overload;
Function SegmentsPerpendicular(Ln1,Ln2:TLine2D):Boolean;                            Overload;

Function SegmentsPerpendicular(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean; Overload;
Function SegmentsPerpendicular(Ln1,Ln2:TLine3D):Boolean;                            Overload;

Procedure SetPlane(xh,xl,yh,yl:TJmFloat);                                             Overload;
Procedure SetPlane(Pnt1,Pnt2:TPoint2D);                                             Overload;
Procedure SetPlane(Rec:TRectangle);                                                 Overload;

Function RectangleIntersect(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;                Overload;
Function RectangleIntersect(Rec1,Rec2:TRectangle):Boolean;                          Overload;

Function CircleInCircle(Cir1,Cir2:TCircle):Boolean;
Function IsTangent(Seg:TSegment2D; Cir:TCircle):Boolean;

Function Distance(x1,y1,x2,y2:TJmFloat):TJmFloat;                                       Overload;
Function Distance(Pnt1,Pnt2:TPoint2D):TJmFloat;                                       Overload;
Function Distance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;                                 Overload;
Function Distance(Pnt1,Pnt2:TPoint3D):TJmFloat;                                       Overload;
Function Distance(Line:TLine2D):TJmFloat;                                             Overload;
Function Distance(Line:TLine3D):TJmFloat;                                             Overload;
Function Distance(Cir1,Cir2:TCircle):TJmFloat;                                        Overload;

Function LayDistance(x1,y1,x2,y2:TJmFloat):TJmFloat;                                    Overload;
Function LayDistance(Pnt1,Pnt2:TPoint2D):TJmFloat;                                    Overload;
Function LayDistance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;                              Overload;
Function LayDistance(Pnt1,Pnt2:TPoint3D):TJmFloat;                                    Overload;
Function LayDistance(Seg:TSegment2D):TJmFloat;                                        Overload;
Function LayDistance(Seg:TSegment3D):TJmFloat;                                        Overload;
Function LayDistance(Cir1,Cir2:TCircle):TJmFloat;                                     Overload;

Function ManhattanDistance(x1,y1,x2,y2:TJmFloat):TJmFloat;                              Overload;
Function ManhattanDistance(Pnt1,Pnt2:TPoint2D):TJmFloat;                              Overload;
Function ManhattanDistance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;                        Overload;
Function ManhattanDistance(Pnt1,Pnt2:TPoint3D):TJmFloat;                              Overload;
Function ManhattanDistance(Line:TLine2D):TJmFloat;                                    Overload;
Function ManhattanDistance(Line:TLine3D):TJmFloat;                                    Overload;
Function ManhattanDistance(Cir1,Cir2:TCircle):TJmFloat;                               Overload;

Function TriangleType(x1,y1,x2,y2,x3,y3:TJmFloat):TTriangleType;                      Overload;
Function TriangleType(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TTriangleType;             Overload;
Function TriangleType(Pnt1,Pnt2,Pnt3:TPoint2D):TTriangleType;                       Overload;
Function TriangleType(Pnt1,Pnt2,Pnt3:TPoint3D):TTriangleType;                       Overload;
Function TriangleType(Tri:TTriangle2D):TTriangleType;                               Overload;
Function TriangleType(Tri:TTriangle3D):TTriangleType;                               Overload;

Function IsEquilateralTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                   Overload;
Function IsEquilateralTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;          Overload;
Function IsEquilateralTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;                    Overload;
Function IsEquilateralTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;                    Overload;
Function IsEquilateralTriangle(Tri:TTriangle2D):Boolean;                            Overload;
Function IsEquilateralTriangle(Tri:TTriangle3D):Boolean;                            Overload;

Function IsIsoscelesTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                     Overload;
Function IsIsoscelesTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;            Overload;
Function IsIsoscelesTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;                      Overload;
Function IsIsoscelesTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;                      Overload;
Function IsIsoscelesTriangle(Tri:TTriangle2D):Boolean;                              Overload;
Function IsIsoscelesTriangle(Tri:TTriangle3D):Boolean;                              Overload;

Function IsRightTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                         Overload;
Function IsRightTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;                Overload;
Function IsRightTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;                          Overload;
Function IsRightTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;                          Overload;
Function IsRightTriangle(Tri:TTriangle2D):Boolean;                                  Overload;
Function IsRightTriangle(Tri:TTriangle3D):Boolean;                                  Overload;

Function IsScaleneTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                       Overload;
Function IsScaleneTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;              Overload;
Function IsScaleneTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;                        Overload;
Function IsScaleneTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;                        Overload;
Function IsScaleneTriangle(Tri:TTriangle2D):Boolean;                                Overload;
Function IsScaleneTriangle(Tri:TTriangle3D):Boolean;                                Overload;

Function IsObtuseTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                        Overload;
Function IsObtuseTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;               Overload;
Function IsObtuseTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;                         Overload;
Function IsObtuseTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;                         Overload;
Function IsObtuseTriangle(Tri:TTriangle2D):Boolean;                                 Overload;
Function IsObtuseTriangle(Tri:TTriangle3D):Boolean;                                 Overload;

Function PntInTriangle(Px,Py,x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;                     Overload;
Function PntInTriangle(Pnt:TPoint2D; Tri:TTriangle2D):Boolean;                      Overload;

Function PntInCircle(Px,Py:TJmFloat; Circle:TCircle):Boolean;                         Overload;
Function PntInCircle(Pnt:TPoint2D; Circle:TCircle):Boolean;                         Overload;
Function TriangleInCircle(Tri:TTriangle2D; Circle:TCircle):Boolean;
Function TriangleOutsideCircle(Tri:TTriangle2D; Circle:TCircle):Boolean;
Function RectangleInCircle(Rect:TRectangle; Circle:TCircle):Boolean;
Function RectangleOutsideCircle(Rect:TRectangle; Circle:TCircle):Boolean;
Function QuadixInCircle(Quad:TQuadix2D; Circle:TCircle):Boolean;
Function QuadixOutsideCircle(Quad:TQuadix2D; Circle:TCircle):Boolean;

Function PntInRectangle(Px,Py:TJmFloat; x1,y1,x2,y2:TJmFloat):Boolean;                  Overload;
Function PntInRectangle(Pnt:TPoint2D; x1,y1,x2,y2:TJmFloat):Boolean;                  Overload;
Function PntInRectangle(Px,Py:TJmFloat; Rec:TRectangle):Boolean;                      Overload;
Function PntInRectangle(Pnt:TPoint2D; Rec:TRectangle):Boolean;                      Overload;
Function TriangleInRectangle(Tri:TTriangle2D; Rec:TRectangle):Boolean;
Function TriangleOutsideRectangle(Tri:TTriangle2D; Rec:TRectangle):Boolean;
Function QuadixInRectangle(Quad:TQuadix2D; Rec:TRectangle):Boolean;
Function QuadixOutsideRectangle(Quad:TQuadix2D; Rec:TRectangle):Boolean;

Function PntInQuadix(Px,Py,x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;                 Overload;
Function PntInQuadix(Pnt,Pnt1,Pnt2,Pnt3,Pnt4: TPoint2D):Boolean;                    Overload;
Function PntInQuadix(Pnt:TPoint2D; Quad:TQuadix2D):Boolean;                         Overload;
Function TriangleInQuadix(Tri:TTriangle2D; Quad:TQuadix2D):Boolean;
Function TriangleOutsideQuadix(Tri:TTriangle2D; Quad:TQuadix2D):Boolean;

Function PntInSphere(x,y,z: TJmFloat; Sphere:TSphere):Boolean;                        Overload;
Function PntInSphere(Pnt3D:TPoint3D; Sphere:TSphere):Boolean;                       Overload;
Function PntOnSphere(Pnt3D:TPoint3D; Sphere:TSphere):Boolean;                       Overload;
Function PolyhedronInSphere(Poly:TPolyhedron; Sphere:TSphere):TInclusion;

Function GeometricSpan(Pnt: Array Of TPoint2D):TJmFloat;                              Overload;
Function GeometricSpan(Pnt: Array Of TPoint3D):TJmFloat;                              Overload;

Procedure CreateEquilateralTriangle(x1,y1,x2,y2: TJmFloat; Var x3,y3:TJmFloat);         Overload;
Procedure CreateEquilateralTriangle(Pnt1,Pnt2:TPoint2D; Var Pnt3:TPoint2D);         Overload;

Procedure TorricelliPoint(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);              Overload;
Function TorricelliPoint(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;                         Overload;
Function TorricelliPoint(Tri:TTriangle2D):TPoint2D;                                 Overload;

Procedure Incenter(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);                     Overload;
Function Incenter(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;                                Overload;
Function Incenter(Tri:TTriangle2D):TPoint2D;                                        Overload;

Procedure Circumcenter(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);                 Overload;
Function Circumcenter(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;                            Overload;
Function Circumcenter(Tri:TTriangle2D):TPoint2D;                                    Overload;

Function TriangleCircumcircle(P1,P2,P3:TPoint2D):TCircle;                           Overload;
Function TriangleCircumcircle(Tri:TTriangle2D):TCircle;                             Overload;
Function InscribedCircle(P1,P2,P3:TPoint2D):TCircle;                                Overload;
Function InscribedCircle(Tri:TTriangle2D):TCircle;                                  Overload;

Function SegmentMidPoint(P1,P2:TPoint2D):TPoint2D;                                  Overload;
Function SegmentMidPoint(Seg:TSegment2D):TPoint2D;                                  Overload;
Function SegmentMidPoint(P1,P2:TPoint3D):TPoint3D;                                  Overload;
Function SegmentMidPoint(Seg:TSegment3D):TPoint3D;                                  Overload;

Function OrthoCenter(x1,y1,x2,y2,x3,y3:TJmFloat):TPoint2D;                            Overload;
Function OrthoCenter(Pnt1,Pnt2,CPnt:TPoint2D):TPoint2D;                             Overload;
Function OrthoCenter(Ln1,Ln2,Ln3:TLine2D):TPoint2D;                                 Overload;
Function OrthoCenter(Tri:TTriangle2D):TPoint2D;                                     Overload;

Function PolygonCentroid(Polygon :TPolygon2D):TPoint2D;                             Overload;
Function PolygonCentroid(Polygon :Array Of TPoint3D):TPoint3D;                      Overload;

Function PolygonSegmentIntersect(Ln:TLine2D; Poly: TPolygon2D):Boolean;
Function PolygonInPolygon(Poly1,Poly2: TPolygon2D):Boolean;
Function PolygonIntersect(Poly1,Poly2: TPolygon2D):Boolean;

Function PntInConvexPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;                Overload;
Function PntInConvexPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;                Overload;

Function PntInConcavePolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;               Overload;
Function PntInConcavePolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;               Overload;

Function PntOnPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;                      Overload;
Function PntOnPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;                      Overload;

Function PntInPolygon(Px,Py,FRx,FRy:TJmFloat; Poly: TPolygon2D):Boolean;              Overload;
Function PntInPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;                      Overload;
Function PntInPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;                      Overload;

Function ConvexQuadix(Quad:TQuadix2D):Boolean;

Function ComplexPolygon(Poly: TPolygon2D):Boolean;
Function SimplePolygon(Poly: TPolygon2D):Boolean;
Function ConvexPolygon(Poly: TPolygon2D):Boolean;
Function ConcavePolygon(Poly: TPolygon2D):Boolean;

Procedure PolygonConstruction(Poly: TPolygon2D);

Function ConvexHull(Polygon:TPolygon2D):TPolygon2D;                                 Overload;
Function ConvexHull(Polyhedron:TPolyhedron):TPolyhedron;                            Overload;

Function RectangularHull(Point: Array Of TPoint2D):TRectangle;                      Overload;
Function RectangularHull(Poly:TPolygon2D):TRectangle;                               Overload;
Function CircularHull(Poly:TPolygon2D):TCircle;
Function SphereHull(Poly: Array Of TPoint3D):TSphere;

Function Clip(Seg:TSegment2D; Rec:TRectangle):TSegment2D;                           Overload;
Function Clip(Seg:TSegment2D; Tri:TTriangle2D):TSegment2D;                          Overload;
Function Clip(Seg:TSegment2D; Quad:TQuadix2D):TSegment2D;                           Overload;

Function Area(Tri:TTriangle2D):TJmFloat;                                              Overload;
Function Area(Tri:TTriangle3D):TJmFloat;                                              Overload;
Function Area(Quad:TQuadix2D):TJmFloat;                                               Overload;
Function Area(Quad:TQuadix3D):TJmFloat;                                               Overload;
Function Area(Rec:TRectangle):TJmFloat;                                               Overload;
Function Area(Cir:TCircle):TJmFloat;                                                  Overload;
Function Area(Poly:TPolygon2D):TJmFloat;                                              Overload;

Function Perimeter(Tri:TTriangle2D):TJmFloat;                                         Overload;
Function Perimeter(Tri:TTriangle3D):TJmFloat;                                         Overload;
Function Perimeter(Quad:TQuadix2D):TJmFloat;                                          Overload;
Function Perimeter(Quad:TQuadix3D):TJmFloat;                                          Overload;
Function Perimeter(Rec:TRectangle):TJmFloat;                                          Overload;
Function Perimeter(Cir:TCircle):TJmFloat;                                             Overload;
Function Perimeter(Poly:TPolygon2D):TJmFloat;                                         Overload;

Procedure Rotate(RotAng:TJmFloat; x,y:TJmFloat; Var Nx,Ny:TJmFloat);                      Overload;
Procedure Rotate(RotAng:TJmFloat; x,y,ox,oy:TJmFloat; Var Nx,Ny:TJmFloat);                Overload;

Function Rotate(RotAng:TJmFloat; Pnt:TPoint2D):TPoint2D;                              Overload;
Function Rotate(RotAng:TJmFloat; Pnt,OPnt:TPoint2D):TPoint2D;                         Overload;
Function Rotate(RotAng:TJmFloat; Seg:TSegment2D):TSegment2D;                          Overload;
Function Rotate(RotAng:TJmFloat; Seg:TSegment2D; OPnt: TPoint2D):TSegment2D;          Overload;
Function Rotate(RotAng:TJmFloat; Tri:TTriangle2D):TTriangle2D;                        Overload;
Function Rotate(RotAng:TJmFloat; Tri:TTriangle2D; OPnt:TPoint2D):TTriangle2D;         Overload;
Function Rotate(RotAng:TJmFloat; Quad:TQuadix2D):TQuadix2D;                           Overload;
Function Rotate(RotAng:TJmFloat; Quad:TQuadix2D; OPnt:TPoint2D):TQuadix2D;            Overload;
Function Rotate(RotAng:TJmFloat; Poly:TPolygon2D):TPolygon2D;                         Overload;
Function Rotate(RotAng:TJmFloat; Poly:TPolygon2D; OPnt:TPoint2D):TPolygon2D;          Overload;

Procedure Rotate(Rx,Ry,Rz:TJmFloat; x,y,z:TJmFloat; Var Nx,Ny,Nz:TJmFloat);               Overload;
Procedure Rotate(Rx,Ry,Rz:TJmFloat; x,y,z,ox,oy,oz:TJmFloat; Var Nx,Ny,Nz:TJmFloat);      Overload;

Function Rotate(Rx,Ry,Rz:TJmFloat; Pnt:TPoint3D):TPoint3D;                            Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Pnt,OPnt:TPoint3D):TPoint3D;                       Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Seg:TSegment3D):TSegment3D;                        Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Seg:TSegment3D; OPnt: TPoint3D):TSegment3D;        Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Tri:TTriangle3D):TTriangle3D;                      Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Tri:TTriangle3D; OPnt:TPoint3D):TTriangle3D;       Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Quad:TQuadix3D):TQuadix3D;                         Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Quad:TQuadix3D; OPnt:TPoint3D):TQuadix3D;          Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Poly:TPolygon3D):TPolygon3D;                       Overload;
Function Rotate(Rx,Ry,Rz:TJmFloat; Poly:TPolygon3D; OPnt:TPoint3D):TPolygon3D;        Overload;


Procedure FastRotate(RotAng:Integer; x,y:TJmFloat; Var Nx,Ny:TJmFloat);                 Overload;
Procedure FastRotate(RotAng:Integer; x,y,ox,oy:TJmFloat; Var Nx,Ny:TJmFloat);           Overload;

Function FastRotate(RotAng:Integer; Pnt:TPoint2D):TPoint2D;                         Overload;
Function FastRotate(RotAng:Integer; Pnt,OPnt:TPoint2D):TPoint2D;                    Overload;
Function FastRotate(RotAng:Integer; Seg:TSegment2D):TSegment2D;                     Overload;
Function FastRotate(RotAng:Integer; Seg:TSegment2D; OPnt: TPoint2D):TSegment2D;     Overload;
Function FastRotate(RotAng:Integer; Tri:TTriangle2D):TTriangle2D;                   Overload;
Function FastRotate(RotAng:Integer; Tri:TTriangle2D; OPnt:TPoint2D):TTriangle2D;    Overload;
Function FastRotate(RotAng:Integer; Quad:TQuadix2D):TQuadix2D;                      Overload;
Function FastRotate(RotAng:Integer; Quad:TQuadix2D; OPnt:TPoint2D):TQuadix2D;       Overload;
Function FastRotate(RotAng:Integer; Poly:TPolygon2D):TPolygon2D;                    Overload;
Function FastRotate(RotAng:Integer; Poly:TPolygon2D; OPnt:TPoint2D):TPolygon2D;     Overload;

Procedure FastRotate(Rx,Ry,Rz:Integer; x,y,z:TJmFloat; Var Nx,Ny,Nz:TJmFloat);          Overload;
Procedure FastRotate(Rx,Ry,Rz:Integer; x,y,z,ox,oy,oz:TJmFloat; Var Nx,Ny,Nz:TJmFloat); Overload;

Function FastRotate(Rx,Ry,Rz:Integer; Pnt:TPoint3D):TPoint3D;                       Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Pnt,OPnt:TPoint3D):TPoint3D;                  Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Seg:TSegment3D):TSegment3D;                   Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Seg:TSegment3D; OPnt: TPoint3D):TSegment3D;   Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Tri:TTriangle3D):TTriangle3D;                 Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Tri:TTriangle3D; OPnt:TPoint3D):TTriangle3D;  Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Quad:TQuadix3D):TQuadix3D;                    Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Quad:TQuadix3D; OPnt:TPoint3D):TQuadix3D;     Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Poly:TPolygon3D):TPolygon3D;                  Overload;
Function FastRotate(Rx,Ry,Rz:Integer; Poly:TPolygon3D; OPnt:TPoint3D):TPolygon3D;   Overload;

Function Translate(Dx,Dy:TJmFloat; Pnt:TPoint2D):TPoint2D;                            Overload;
Function Translate(Dx,Dy:TJmFloat; Ln:TLine2D):TLine2D;                               Overload;
Function Translate(Dx,Dy:TJmFloat; Seg:TSegment2D):TSegment2D;                        Overload;
Function Translate(Dx,Dy:TJmFloat; Tri:TTriangle2D):TTriangle2D;                      Overload;
Function Translate(Dx,Dy:TJmFloat; Quad:TQuadix2D):TQuadix2D;                         Overload;
Function Translate(Dx,Dy:TJmFloat; Rec:TRectangle):TRectangle;                        Overload;
Function Translate(Dx,Dy:TJmFloat; Cir:TCircle):TCircle;                              Overload;
Function Translate(Dx,Dy:TJmFloat; Poly: TPolygon2D):TPolygon2D;                      Overload;
Function Translate(Pnt:TPoint2D; Poly: TPolygon2D):TPolygon2D;                      Overload;

Function Translate(Dx,Dy,Dz:TJmFloat; Pnt:TPoint3D):TPoint3D;                         Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Ln:TLine3D):TLine3D;                            Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Seg:TSegment3D):TSegment3D;                     Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Tri:TTriangle3D):TTriangle3D;                   Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Quad:TQuadix3D):TQuadix3D;                      Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Sphere:TSphere):TSphere;                        Overload;
Function Translate(Dx,Dy,Dz:TJmFloat; Poly: TPolygon3D):TPolygon3D;                   Overload;
Function Translate(Pnt:TPoint3D; Poly: TPolygon3D):TPolygon3D;                      Overload;

Function Scale(Dx,Dy:TJmFloat; Pnt:TPoint2D):TPoint2D;                                Overload;
Function Scale(Dx,Dy:TJmFloat; Ln:TLine2D):TLine2D;                                   Overload;
Function Scale(Dx,Dy:TJmFloat; Seg:TSegment2D):TSegment2D;                            Overload;
Function Scale(Dx,Dy:TJmFloat; Tri:TTriangle2D):TTriangle2D;                          Overload;
Function Scale(Dx,Dy:TJmFloat; Quad:TQuadix2D):TQuadix2D;                             Overload;
Function Scale(Dx,Dy:TJmFloat; Rec:TRectangle):TRectangle;                            Overload;
Function Scale(Dr:TJmFloat; Cir:TCircle):TCircle;                                     Overload;
Function Scale(Dx,Dy:TJmFloat; Poly: TPolygon2D):TPolygon2D;                          Overload;

Function Scale(Dx,Dy,Dz:TJmFloat; Pnt:TPoint3D):TPoint3D;                             Overload;
Function Scale(Dx,Dy,Dz:TJmFloat; Ln:TLine3D):TLine3D;                                Overload;
Function Scale(Dx,Dy,Dz:TJmFloat; Seg:TSegment3D):TSegment3D;                         Overload;
Function Scale(Dx,Dy,Dz:TJmFloat; Tri:TTriangle3D):TTriangle3D;                       Overload;
Function Scale(Dx,Dy,Dz:TJmFloat; Quad:TQuadix3D):TQuadix3D;                          Overload;
Function Scale(Dr:TJmFloat; Sphere:TSphere):TSphere;                                  Overload;
Function Scale(Dx,Dy,Dz:TJmFloat; Poly: TPolygon3D):TPolygon3D;                       Overload;

Procedure ShearXAxis(Shear,x,y:TJmFloat; Var Nx,Ny:TJmFloat);                           Overload;
Function ShearXAxis(Shear:TJmFloat; Pnt:TPoint2D):TPoint2D;                           Overload;
Function ShearXAxis(Shear:TJmFloat; Seg:TSegment2D):TSegment2D;                       Overload;
Function ShearXAxis(Shear:TJmFloat; Tri:TTriangle2D):TTriangle2D;                     Overload;
Function ShearXAxis(Shear:TJmFloat; Quad:TQuadix2D):TQuadix2D;                        Overload;
Function ShearXAxis(Shear:TJmFloat; Poly:TPolygon2D):TPolygon2D;                      Overload;

Procedure ShearYAxis(Shear,x,y:TJmFloat; Var Nx,Ny:TJmFloat);                           Overload;
Function ShearYAxis(Shear:TJmFloat; Pnt:TPoint2D):TPoint2D;                           Overload;
Function ShearYAxis(Shear:TJmFloat; Seg:TSegment2D):TSegment2D;                       Overload;
Function ShearYAxis(Shear:TJmFloat; Tri:TTriangle2D):TTriangle2D;                     Overload;
Function ShearYAxis(Shear:TJmFloat; Quad:TQuadix2D):TQuadix2D;                        Overload;
Function ShearYAxis(Shear:TJmFloat; Poly:TPolygon2D):TPolygon2D;                      Overload;

Function EquatePoint(x,y:TJmFloat):TPoint2D;                                          Overload;
Function EquatePoint(x,y,z:TJmFloat):TPoint3D;                                        Overload;

Function EquateSegment(x1,y1,x2,y2:TJmFloat):TSegment2D;                              Overload;
Function EquateSegment(x1,y1,z1,x2,y2,z2:TJmFloat):TSegment3D;                        Overload;

Function EquateQuadix(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):TQuadix2D;                    Overload;
Function EquateQuadix(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):TQuadix3D;        Overload;

Function EquateRectangle(x1,y1,x2,y2:TJmFloat):TRectangle;

Function EquateTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):TTriangle2D;                      Overload;
Function EquateTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TTriangle3D;             Overload;
Function EquateTriangle(Pnt1,Pnt2,Pnt3: TPoint2D):TTriangle2D;                      Overload;
Function EquateTriangle(Pnt1,Pnt2,Pnt3: TPoint3D):TTriangle3D;                      Overload;

Function EquateCircle(x,y,r:TJmFloat):TCircle;
Function EquateSphere(x,y,z,r:TJmFloat):TSphere;

Function EquatePlane(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TPlane3D;                   Overload;
Function EquatePlane(Pnt1,Pnt2,Pnt3:TPoint3D):TPlane3D;                             Overload;

Procedure GenerateRandomPoints(Bx1,By1,Bx2,By2:TJmFloat; Var Point: Array Of TPoint2D);


Function Add(Vec1,Vec2:TVector2D):TVector2D;                                        Overload;
Function Add(Vec1,Vec2:TVector3D):TVector3D;                                        Overload;

Function Sub(Vec1,Vec2:TVector2D):TVector2D;                                        Overload;
Function Sub(Vec1,Vec2:TVector3D):TVector3D;                                        Overload;

Function Mul(Vec1,Vec2:TVector2D):TVector3D;                                        Overload;
Function Mul(Vec1,Vec2:TVector3D):TVector3D;                                        Overload;

Function UnitVector(Vec:TVector2D):TVector2D;                                       Overload;
Function UnitVector(Vec:TVector3D):TVector3D;                                       Overload;

Function Magnitude(Vec:TVector2D):TJmFloat;                                           Overload;
Function Magnitude(Vec:TVector3D):TJmFloat;                                           Overload;

Function DotProduct(Vec1,Vec2:TVector2D):TJmFloat;                                    Overload;
Function DotProduct(Vec1,Vec2:TVector3D):TJmFloat;                                    Overload;

Function Scale(Vec:TVector2D; Factor:TJmFloat):TVector2D;                             Overload;
Function Scale(Vec:TVector3D; Factor:TJmFloat):TVector3D;                             Overload;
Function Scale(Factor:TJmFloat; Vec:TVector3D):TVector3D;                             Overload;

Function Negate(Vec:TVector2D):TVector2D;                                           Overload;
Function Negate(Vec:TVector3D):TVector3D;                                           Overload;


Function IsEqual(Val1,Val2:TJmFloat):Boolean;                                         Overload;
Function IsEqual(Pnt1,Pnt2:TPoint2D):Boolean;                                       Overload;
Function IsEqual(Pnt1,Pnt2:TPoint3D):Boolean;                                       Overload;

Function NotEqual(Val1,Val2:TJmFloat):Boolean;                                        Overload;
Function NotEqual(Pnt1,Pnt2:TPoint2D):Boolean;                                      Overload;
Function NotEqual(Pnt1,Pnt2:TPoint3D):Boolean;                                      Overload;


Const PI2       =  6.283185307179586476925286766559000;
Const PIDiv180  =  0.017453292519943295769236907684886;
Const _180DivPI = 57.295779513082320876798154814105000;
Const Epsilon   = 1.0E-12;

Var

 (* 2D/3D Portal Definition *)
 MaximumX         : TJmFloat;
 MinimumX         : TJmFloat;
 MaximumY         : TJmFloat;
 MinimumY         : TJmFloat;
 MaximumZ         : TJmFloat;
 MinimumZ         : TJmFloat;

 (*  Polygon Anchor  *)
 PolyOrthoCenterX : TJmFloat;
 PolyOrthoCenterY : TJmFloat;
 PolyOrthoCenterZ : TJmFloat;

 SinTable : Array Of TJmFloat;
 CosTable : Array Of TJmFloat;
 TanTable : Array Of TJmFloat;

Procedure InitialiseTrigonometryTables;

Implementation

Uses Math;


(*****************************************************************************)
(********************* TGeometry Class Implementation ************************)
(*****************************************************************************)


Function Orientation(x1,y1,x2,y2,Px,Py:TJmFloat):Integer;
Var Orin : TJmFloat;
Begin
 (* Linear determinant of the 3 points *)
 Orin:=(x2-x1)*(py-y1)-(px-x1)*(y2-y1);

 If Orin > 0.0 Then Result := +1    (* Orientaion is to the right-hand side  *)
  Else
   If Orin < 0.0 Then Result := -1  (* Orientaion is to the left-hand side   *)
     Else
      Result := 0;                  (* Orientaion is neutral if result is 0  *)
End;
(* End Of Orientation *)


Function Orientation(x1,y1,z1,x2,y2,z2,x3,y3,z3,Px,Py,Pz:TJmFloat):Integer;
Var  Px1,Px2,Px3 : TJmFloat;
     Py1,Py2,Py3 : TJmFloat;
     Pz1,Pz2,Pz3 : TJmFloat;
     Orin        : TJmFloat;
Begin

 Px1 := x1 - px;
 Px2 := x2 - px;
 Px3 := x3 - px;

 Py1 := y1 - py;
 Py2 := y2 - py;
 Py3 := y3 - py;

 Pz1 := z1 - pz;
 Pz2 := z2 - pz;
 Pz3 := z3 - pz;

 Orin  := Px1*(Py2 * Pz3 - Pz2 * Py3)+
          Px2*(Py3 * Pz1 - Pz3 * Py1)+
          Px3*(Py1 * Pz2 - Pz1 * Py2);

 If Orin < 0.0  Then Result := -1    (* Orientaion is below plane                      *)
  Else
   If Orin > 0.0 Then Result := +1   (* Orientaion is above plane                      *)
    Else
     Result := 0;                    (* Orientaion is coplanar to plane if result is 0 *)

End;
(* End Of Orientation *)


Function Orientation(Pnt1,Pnt2:TPoint2D; Px,Py:TJmFloat):Integer;
Begin
 Result := Orientation(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Px,Py);
End;
(* End Of Orientation *)


Function Orientation(Pnt1,Pnt2,Pnt3:TPoint2D):Integer;
Begin
 Result := Orientation(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of Orientation *)


Function Orientation(Ln:TLine2D; Pnt:TPoint2D):Integer;
Begin
 Result := Orientation(Ln[1].x,Ln[1].y,Ln[2].x,Ln[2].y,Pnt.x,Pnt.y);
End;
(* End Of Orientation *)


Function Orientation(Seg:TSegment2D; Pnt:TPoint2D):Integer;
Begin
 Result := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Pnt.x,Pnt.y);
End;
(* End Of Orientation *)


Function Orientation(Pnt1,Pnt2,Pnt3:TPoint3D; Px,Py,Pz:TJmFloat):Integer;
Begin
 Result := Orientation(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z,Px,Py,Pz);
End;
(* End Of Orientation *)


Function Orientation(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):Integer;
Begin
 Result := Orientation(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z,Pnt4.x,Pnt4.y,Pnt4.z);
End;
(* End Of Orientation *)


Function Orientation(Tri:TTriangle3D; Pnt:TPoint3D):Integer;
Begin
 Result := Orientation(Tri[1],Tri[2],Tri[3],Pnt);
End;
(* End Of Orientation *)


Function Signed(x1,y1,x2,y2,Px,Py:TJmFloat):TJmFloat;
Begin
 Result := (x2 - x1)*(py - y1)-(px - x1)*(y2 - y1);
End;
(* End Of Signed *)


Function Signed(x1,y1,z1,x2,y2,z2,x3,y3,z3,Px,Py,Pz:TJmFloat):TJmFloat;
Var  Px1,Px2,Px3 : TJmFloat;
     Py1,Py2,Py3 : TJmFloat;
     Pz1,Pz2,Pz3 : TJmFloat;
Begin

 Px1 := x1 - px;
 Px2 := x2 - px;
 Px3 := x3 - px;

 Py1 := y1 - py;
 Py2 := y2 - py;
 Py3 := y3 - py;

 Pz1 := z1 - pz;
 Pz2 := z2 - pz;
 Pz3 := z3 - pz;

 Result:= Px1*(Py2 * Pz3 - Pz2 * Py3)+
          Px2*(Py3 * Pz1 - Pz3 * Py1)+
          Px3*(Py1 * Pz2 - Pz1 * Py2);
End;
(* End Of Signed *)


Function Signed(Pnt1,Pnt2:TPoint2D; Px,Py:TJmFloat):TJmFloat;
Begin
 Result := Signed(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Px,Py);
End;
(* End Of Signed *)


Function Signed(Pnt1,Pnt2,Pnt3:TPoint2D):TJmFloat;
Begin
 Result := Signed(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of Signed *)


Function Signed(Ln:TLine2D; Pnt:TPoint2D):TJmFloat;
Begin
 Result := Signed(Ln[1].x,Ln[1].y,Ln[2].x,Ln[2].y,Pnt.x,Pnt.y);
End;
(* End Of Signed *)


Function Signed(Seg:TSegment2D; Pnt:TPoint2D):TJmFloat;
Begin
 Result := Signed(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Pnt.x,Pnt.y);
End;
(* End Of Signed *)


Function Signed(Pnt1,Pnt2,Pnt3:TPoint3D; Px,Py,Pz:TJmFloat):TJmFloat;
Begin
 Result := Signed(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z,Px,Py,Pz);
End;
(* End Of Signed *)


Function Signed(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):TJmFloat;
Begin
 Result := Signed(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z,Pnt4.x,Pnt4.y,Pnt4.z);
End;
(* End Of Signed *)


Function Signed(Tri:TTriangle3D; Pnt:TPoint3D):TJmFloat;
Begin
 Result := Signed(Tri[1],Tri[2],Tri[3],Pnt);
End;
(* End Of Signed *)


Function Collinear(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Begin
 Result := IsEqual((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1),0);
End;
(* End Of Collinear *)


Function Collinear(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var Dx1,Dx2  : TJmFloat;
    Dy1,Dy2  : TJmFloat;
    Dz1,Dz2  : TJmFloat;
    Cx,Cy,Cz : TJmFloat;
//Var AB,AC,BC:TJmFloat;
Begin

 {find the difference between the 2 points P2 and P3 to P1 }
 Dx1 := x2 - x1;
 Dy1 := y2 - y1;
 Dz1 := z2 - z1;

 Dx2 := x3 - x1;
 Dy2 := y3 - y1;
 Dz2 := z3 - z1;

 {perform a 3d cross product}
 Cx  := Dy1*Dz2- Dy2*Dz1;
 Cy  := Dx2*Dz1- Dx1*Dz2;
 Cz  := Dx1*Dy2- Dx2*Dy1;

 Result := IsEqual(Cx*Cx + Cy*Cy + Cz*Cz,0.0);

 {
  Note:
   The method below is very stable and logical, however at the same time
   it is "VERY" inefficient, it requires 3 SQRTs which is not acceptable...
 Result:=False;
 AB:=Distance(x1,y1,z1,x2,y2,z2);
 AC:=Distance(x1,y1,z1,x3,y3,z3);
 BC:=Distance(x2,y2,z2,x3,y3,z3);

 If (AB+AC) = BC Then Result:=True
  Else
   If (AB+BC) = AC Then Result:=True
    Else
     If (AC+BC) = AB Then Result:=True;
 }

End;
(* End Of Collinear *)


Function Collinear(PntA,PntB,PntC:TPoint2D):Boolean;
Begin
 Result := Collinear(PntA.x,PntA.y,PntB.x,PntB.y,PntC.x,PntC.y);
End;
(* End Of Collinear *)


Function Collinear(PntA,PntB,PntC:TPoint3D):Boolean;
Begin
 Result := Collinear(PntA.x,PntA.y,PntA.z,PntB.x,PntB.y,PntB.z,PntC.x,PntC.y,PntC.z);
End;
(* End Of Collinear *)

Function IsPntCollinear(x1,y1,x2,y2,Px,Py:TJmFloat):Boolean;
Var MinX, MinY : TJmFloat;
    MaxX, MaxY : TJmFloat;
Begin
 {
  This method will return trrue iff the point (px,py) is collinear
  to points (x1,y1) and (x2,y2) and exists on the segment A->B
 }
 Result:=False;

 If Not Collinear(x1,y1,x2,y2,Px,Py) Then Exit;

 If x1 < x2 Then
  Begin
   MinX := x1;
   MaxX := x2;
  End
  Else
   Begin
    MinX := x2;
    MaxX := x1;
   End;

 If y1 < y2 Then
  Begin
   MinY := y1;
   MaxY := y2;
  End
  Else
   Begin
    MinY := y2;
    MaxY := y1;
   End;

 Result := (MinX <= Px) And (Px <= MaxX) And
           (MinY <= Py) And (Py <= MaxY);

End;
(* End Of IsPntCollinear *)


Function IsPntCollinear(PntA,PntB,PntC:TPoint2D):Boolean;
Begin
 {
  This method will return trrue iff the pointC is collinear
  to points A and B and exists on the segment A->B
 }
 Result := IsPntCollinear(PntA.x,PntA.y,PntB.x,PntB.y,PntC.x,PntC.y);
End;
(* End Of IsPntCollinear *)


Function IsPntCollinear(Line:TLine2D; PntC:TPoint2D):Boolean;
Begin
 Result := IsPntCollinear(Line[1],Line[2],PntC);
End;
(* End Of IsPntCollinear *)


Function IsPntCollinear(x1,y1,z1,x2,y2,z2,Px,Py,Pz:TJmFloat):Boolean;
Var MinX, MinY, MinZ : TJmFloat;
    MaxX, MaxY, MaxZ : TJmFloat;
Begin
 {
  This method will return true iff the pointC is collinear
  to points A and B and exists on the segment A->B
 }
 Result := False;
 If Not Collinear(x1,y1,z1,x2,y2,z2,Px,Py,Pz) Then Exit;

 If x1 < x2 Then
  Begin
   MinX := x1;
   MaxX := x2;
  End
  Else
   Begin
    MinX := x2;
    MaxX := x1;
   End;

 If y1 < y2 Then
  Begin
   MinY := y1;
   MaxY := y2;
  End
  Else
   Begin
    MinY := y2;
    MaxY := y1;
   End;

 If z1 < z2 Then
  Begin
   MinZ := z1;
   MaxZ := z2;
  End
  Else
   Begin
    MinZ := z2;
    MaxZ := z1;
   End;

 Result := (MinX <= Px) And (Px <= MaxX) And
           (MinY <= Py) And (Py <= MaxY) And
           (MinZ <= Pz) And (Pz <= MaxZ);
End;
(* End Of IsPntCollinear *)


Function IsPntCollinear(PntA,PntB,PntC:TPoint3D):Boolean;
Begin
 Result := IsPntCollinear(PntA.x,PntA.y,PntA.z,PntB.x,PntB.y,PntB.z,PntC.x,PntC.y,PntC.z);
End;
(* End Of IsPntCollinear *)


Function IsPntCollinear(Line:TLine3D; PntC:TPoint3D):Boolean;
Begin
 Result := IsPntCollinear(Line[1],Line[2],PntC);
End;
(* End Of IsPntCollinear *)


Function IsOnRightSide(x,y:TJmFloat; Ln:TLine2D):Boolean;
Begin
 Result := (Orientation(Ln[1].x,Ln[1].y,Ln[2].x,Ln[2].y,x,y) < 0);
End;
(* End Of IsOnRightSide *)


Function IsOnRightSide(Pnt:TPoint2D; Ln:TLine2D):Boolean;
Begin
 Result := (Orientation(Ln,Pnt) < 0);
End;
(* End Of IsOnRightSide *)


Function IsOnLeftSide(x,y:TJmFloat; Ln:TLine2D):Boolean;
Begin
 Result := (Orientation(Ln[1].x,Ln[1].y,Ln[2].x,Ln[2].y,x,y) > 0);
End;
(* End Of IsOnLeftSide *)


Function IsOnLeftSide(Pnt:TPoint2D; Ln:TLine2D):Boolean;
Begin
 Result := (Orientation(Ln,Pnt) > 0);
End;
(* End Of IsOnLeftSide *)


Function Intersect(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;
Begin
 Result := (Orientation(x1,y1,x2,y2,x3,y3) <> Orientation(x1,y1,x2,y2,x4,y4)) And
           (Orientation(x3,y3,x4,y4,x1,y1) <> Orientation(x3,y3,x4,y4,x2,y2));
End;
(* End Of SegmentIntersect *)


Function Intersect(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):Boolean;
Begin
 Result := Intersect(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Pnt4.x,Pnt4.y);
End;
(* End Of Intersect *)


Function Intersect(Seg1,Seg2:TSegment2D):Boolean;
Begin
 Result := Intersect(Seg1[1],Seg1[2],Seg2[1],Seg2[2]);
End;
(* End Of Intersect *)


Function Intersect(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean;
Begin
 Result := False;

{
 This area has yet to be completed.
 Result := (Orientation(x1,y1,z1,x2,y2,z3,x3,y3,z3,x4,y4,z4) <> Orientation(x1,y1,z1,x2,y2,z2,x4,y4,z4,x3,y3,z3)) And
           (Orientation(x3,y3,z3,x4,y4,z4,x1,y1,z1,x2,y2,z2) <> Orientation(x3,y3,z3,x4,y4,z4,x2,y2,z2,x1,y1,z1));
}

End;


Function Intersect(P1,P2,P3,P4:TPoint3D):Boolean;
Begin
 Result := Intersect(P1.x,P1.y,P1.z,P2.x,P2.y,P2.z,P3.x,P3.y,P3.z,P4.x,P4.y,P4.z);
End;
(* End Of Intersect *)


Function Intersect(Seg1,Seg2:TSegment3D):Boolean;
Begin
 Result := Intersect(Seg1[1],Seg1[2],Seg2[1],Seg2[2]);
End;
(* End Of Intersect *)


Function Intersect(Seg:TSegment2D; Rec:TRectangle):Boolean;
Var P1,P2:Boolean;
    CO,PO: TJmFloat;
Begin
 P1 := PntInRectangle(Seg[1],Rec);
 P2 := PntInRectangle(Seg[2],Rec);

 {
   If both points lie within the rectangle
 }
 Result := False;
 If P1 And P2 Then Exit;

 {
   If one of the points lies within the rectangle and the
   other outside of the rectangle
 }
 Result := True;
 If (P1 And (Not P2)) Or
    (P2 And (Not P1)) Then Exit;

 {
   If both points lie outside the rectangle, and a constant
   orientation is encounrted, it can then be assumed that
   the segment does not intersect the rectangle.
 }

 PO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Rec[1].x,Rec[1].y);

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Rec[2].x,Rec[1].y);
 If CO <> PO Then Exit;

 PO := CO;
 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Rec[2].x,Rec[2].y);
 If CO <> PO Then Exit;

 PO := CO;
 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Rec[1].x,Rec[2].y);
 If CO <> PO Then Exit;

 Result:= False;

End;
(* End Of Intersect *)


Function Intersect(Seg:TSegment2D; Tri:TTriangle2D):Boolean;
Var P1,P2 : Boolean;
    CO,PO : TJmFloat;
Begin

 Result := False;

 P1 := PntInTriangle(Seg[1],Tri);
 P2 := PntInTriangle(Seg[2],Tri);

 {
  If both points lie within the triangle
 }
 If P1 And P2 Then Exit;


 {

   If one of the points lies within the triangle and the
   other outside of the rectangle
 }
 Result:= True;
 If (P1 And (Not P2)) Or
    (P2 And (Not P1)) Then Exit;


 {
   If both points lie outside the triangle, and a constant
   orientation is encountered, it can then be assumed that
   the segment does not intersect the triangle.
   Hence a test for continual orientation is done.
 }

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Tri[1].x,Tri[1].y);
 PO := CO;

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Tri[2].x,Tri[2].y);
 If CO <> PO Then Exit;
 PO := CO;

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Tri[3].x,Tri[3].y);
 If CO <> PO Then Exit;

 Result := False;

End;
(* End Of Intersect *)


Function Intersect(Seg:TSegment2D; Quad:TQuadix2D):Boolean;
Var P1,P2 : Boolean;
    CO,PO : TJmFloat;
Begin

 P1 := PntInQuadix(Seg[1],Quad);
 P2 := PntInQuadix(Seg[2],Quad);

 {
  If both points lie within the Quadix
 }
 Result := False;
 If P1 And P2 Then Exit;

 {
   If one of the points lies within the quadix and the
   other outside of the quadix
 }
 Result := True;
 If Not(P1 And  P2) Then Exit;


 {
   At this point it is assumed both points lie outside of
   the quadix.
   If both points lie outside the quadix, and a constant
   orientation is encountered, it can then be assumed that
   the segment does not intersect the quadix.
   Hence a test for continual orientation is done.
 }

 Result := True;

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Quad[1].x,Quad[1].y);
 PO := CO;

 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Quad[2].x,Quad[2].y);
 If CO <> PO Then Exit;

 PO := CO;
 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Quad[3].x,Quad[3].y);
 If CO <> PO Then Exit;

 PO := CO;
 CO := Orientation(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Quad[4].x,Quad[4].y);
 If CO <> PO Then Exit;

 {
  Reaching this point means that the segment is actually outside
  of the quadix and is not intersecting with any of the edges.
 }
 Result := False;

End;
(* End Of Intersect *)


Function Intersect(Seg:TSegment2D; Cir:TCircle):Boolean;
Begin
 {
  It is assumed that an intersection by a segment is either
  a full (2 points) partial (1 point) or tangential. Anything
  else will result in a false output.
 }
 Seg    := Translate(-Cir.x,-Cir.y,Seg);
 Result := (((Cir.Radius*Cir.Radius)*LayDistance(Seg)-Sqr(Seg[1].x*Seg[2].y-Seg[2].x*Seg[1].y)) >= 0);
End;
(* End Of Intersect *)


Function Intersect(Seg:TSegment3D; Sphere:TSphere):Boolean;
Var  A, B, C : TJmFloat;
Begin
 A := LayDistance(Seg);
 B := 2*((Seg[2].x-Seg[1].x)*(Seg[1].x-Sphere.x)+(Seg[2].y-Seg[1].y)*(Seg[1].y-Sphere.y)+(Seg[2].z-Seg[1].z)*(Seg[1].z-Sphere.z));
 C := Sqr(Sphere.x)+Sqr(Sphere.y)+Sqr(Sphere.z)+Sqr(Seg[1].x)+Sqr(Seg[1].y)+Sqr(Seg[1].z)-2*(Sphere.x*Seg[1].x+Sphere.y*Seg[1].y+Sphere.z*Seg[1].z)-Sqr(Sphere.Radius);
 Result:=((B*B-4*A*C) >= 0)
End;
(* End Of Intersect *)


Procedure IntersectPoint(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat; Var Nx,Ny:TJmFloat);
Var R           : TJmFloat;
    dx1,dx2,dx3 : TJmFloat;
    dy1,dy2,dy3 : TJmFloat;
Begin
 dx1 := x2 - x1;
 dx2 := x4 - x3;
 dx3 := x1 - x3;

 dy1 := y2 - y1;
 dy2 := y1 - y3;
 dy3 := y4 - y3;

 R:= dx1*dy3 - dy1*dx2;

 If R <> 0 Then
  Begin
   R  := (dy2*(x4-x3)-dx3*dy3)/R;
   Nx := x1 + R*dx1;
   Ny := y1 + R*dy1;
  End
  Else
   Begin
    If Collinear(x1,y1,x2,y2,x3,y3) Then
     Begin
      Nx := x3;
      Ny := y3;
     End
     Else
      Begin
       Nx := x4;
       Ny := y4;
      End;
   End;

End;


Procedure IntersectPoint(P1,P2,P3,P4:TPoint2D; Var Nx,Ny:TJmFloat);
Begin
 IntersectPoint(P1.x,P1.y,P2.x,P2.y,P3.x,P3.y,P4.x,P4.y,Nx,Ny);
End;
(* End Of IntersectPoint *)


Function IntersectPoint(P1,P2,P3,P4:TPoint2D):TPoint2D;
Begin
 IntersectPoint(P1.x,P1.y,P2.x,P2.y,P3.x,P3.y,P4.x,P4.y,Result.x,Result.y);
End;
(* End Of IntersectPoint *)


Function IntersectPoint(Seg1,Seg2:TSegment2D):TPoint2D;
Begin
 Result := IntersectPoint(Seg1[1],Seg1[2],Seg2[1],Seg2[2]);
End;
(* End Of IntersectPoint *)


Procedure IntersectPoint(Cir1,Cir2:TCircle; Var Pnt1,Pnt2:TPoint2D);
Var Dist   : TJmFloat;
    A      : TJmFloat;
    H      : TJmFloat;
    RatioA : TJmFloat;
    RatioH : TJmFloat;
    Dx     : TJmFloat;
    Dy     : TJmFloat;
    Ph     : TPoint2D;
Begin
 Dist    := Distance(Cir1,Cir2);
 A       := (Dist*Dist-Cir1.Radius*Cir1.Radius-Cir2.Radius*Cir1.Radius)/(2*Dist);
 H       := Sqrt(Cir1.Radius*Cir1.Radius-A*A);
 RatioA  := A/Dist;
 RatioH  := H/Dist;

 Dx      := Cir1.x-Cir2.x;
 Dy      := Cir1.y-Cir2.y;

 Ph.x    := Cir1.x+RatioA*Dx;
 Ph.y    := Cir1.y+RatioA*Dy;

 Dx      := Dx*RatioH;
 Dy      := Dy*RatioH;

 Pnt1.x  := Ph.x + Dx;
 Pnt1.y  := Ph.y - Dy;

 Pnt2.x  := Ph.x - Dx;
 Pnt2.y  := Ph.y + Dy;

End;
(* End Of IntersectPoint *)


Function VertexAngle(x1,y1,x2,y2,x3,y3:TJmFloat):TJmFloat;
Var Dist : TJmFloat;
Begin
 (* Quantify coordinates *)
 x1   := x1 - x2;
 x3   := x3 - x2;
 y1   := y1 - y2;
 y3   := y3 - y2;

 (* Calculate Lay Distance *)
 Dist := (x1*x1+y1*y1)*(x3*x3+y3*y3);

 If IsEqual(Dist,0) Then Result := 0.0
  Else
   Result := ArcCos((x1*x3+y1*y3)/sqrt(Dist))*_180DivPI;
End;
(* End Of VertexAngle *)


Function VertexAngle(Pnt1,Pnt2,Pnt3:TPoint2D):TJmFloat;
Begin
 Result := VertexAngle(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of VertexAngle *)


Function VertexAngle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TJmFloat;
Var Dist : TJmFloat;
Begin
 (* Quantify coordinates *)
 x1 := x1 - x2;
 x3 := x3 - x2;
 y1 := y1 - y2;
 y3 := y3 - y2;
 z1 := z1 - z2;
 z3 := z3 - z2;

 (* Calculate Lay Distance *)
 Dist := (x1*x1+y1*y1+z1*z1)*(x3*x3+y3*y3+z3*z3);

 If IsEqual(Dist,0) Then Result := 0.0
  Else
   Result := ArcCos((x1*x3+y1*y3+z1*z3)/sqrt(Dist))*_180DivPI;
End;
(* End Of VertexAngle *)



Function VertexAngle(Pnt1,Pnt2,Pnt3:TPoint3D):TJmFloat;
Begin
 Result := VertexAngle(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z);
End;
(* End Of VertexAngle *)


Function SegmentIntersectAngle(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):TJmFloat;
Var TempPnt : TPoint2D;
Begin
 Result := -1;
 If Intersect(Pnt1,Pnt2,Pnt3,Pnt4) Then
  Begin
   TempPnt := IntersectPoint(Pnt1,Pnt2,Pnt3,Pnt4);
   Result  := VertexAngle(Pnt1,TempPnt,Pnt4);
  End;
End;
(* End Of SegmentIntersectAngle *)


Function SegmentIntersectAngle(Seg1,Seg2:TSegment2D):TJmFloat;
Var TempPnt : TPoint2D;
Begin
 Result := -1;
 If Intersect(Seg1,Seg2) Then
  Begin
   TempPnt := IntersectPoint(Seg1,Seg2);
   Result  := VertexAngle(Seg1[1],TempPnt,Seg2[1]);
  End;
End;
(* End Of SegmentIntersectAngle *)


Function SegmentIntersectAngle(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):TJmFloat;
Begin
 {
  This section can be completed once line intersection in 3D is complete
 }
 Result := 0.0;
End;
(* End Of SegmentIntersectAngle *)


Function SegmentIntersectAngle(Seg1,Seg2:TSegment3D):TJmFloat;
Begin
{
 This section can be completed once line intersection in 3D is complete
}
 Result := 0.0;
End;
(* End Of SegmentIntersectAngle *)


Function InPortal(P:TPoint2D):Boolean;
Begin
 Result := PntInRectangle(P,MinimumX,MinimumY,MaximumX,MaximumY);
End;
(* End Of InPortal *)


Function InPortal(P:TPoint3D):Boolean;
Begin
 Result := (MinimumX <= P.x) And (MaximumZ >= P.x) And
           (MinimumY <= P.y) And (MaximumY >= P.y) And
           (MinimumZ <= P.y) And (MaximumZ >= P.y);
End;
(* End Of InPortal *)


Function HighestPoint(Polygon: TPolygon2D):TPoint2D;
Var I : Integer;
    TempPnt : TPoint2D;
Begin
 TempPnt.y := MinimumY;
 For I:= 0 To Length(Polygon)-1 Do
  If Polygon[I].y > TempPnt.y Then TempPnt := Polygon[I];
 Result := TempPnt;
End;
(* End Of HighestPoint *)


Function HighestPoint(Tri:TTriangle2D):TPoint2D;
Begin
 Result.y := MinimumY;
 If Tri[1].y > Result.y Then Result := Tri[1];
 If Tri[2].y > Result.y Then Result := Tri[2];
 If Tri[3].y > Result.y Then Result := Tri[3];
End;
(* End Of HighestPoint *)


Function HighestPoint(Tri:TTriangle3D):TPoint3D;
Begin
 Result.y := MinimumY;
 If Tri[1].y > Result.y Then Result := Tri[1];
 If Tri[2].y > Result.y Then Result := Tri[2];
 If Tri[3].y > Result.y Then Result := Tri[3];
End;
(* End Of HighestPoint *)


Function HighestPoint(Quadix:TQuadix2D):TPoint2D;
Begin
 Result.y := MinimumY;
 If Quadix[1].y > Result.y Then Result := Quadix[1];
 If Quadix[2].y > Result.y Then Result := Quadix[2];
 If Quadix[3].y > Result.y Then Result := Quadix[3];
 If Quadix[4].y > Result.y Then Result := Quadix[4];
End;
(* End Of HighestPoint *)


Function HighestPoint(Quadix:TQuadix3D):TPoint3D;
Begin
 Result.y := MinimumY;
 If Quadix[1].y > Result.y Then Result := Quadix[1];
 If Quadix[2].y > Result.y Then Result := Quadix[2];
 If Quadix[3].y > Result.y Then Result := Quadix[3];
 If Quadix[4].y > Result.y Then Result := Quadix[4];
End;
(* End Of HighestPoint *)


Function LowestPoint(Polygon: TPolygon2D):TPoint2D;
Var I:Integer;
Begin
 Result.y := MaximumY;
 For I:= 0 To Length(Polygon)-1 Do
  If Polygon[I].y < Result.y Then Result := Polygon[I];
End;
(* End Of LowestPoint *)


Function LowestPoint(Tri:TTriangle2D):TPoint2D;
Begin
 Result.y := MaximumY;
 If Tri[1].y < Result.y Then Result := Tri[1];
 If Tri[2].y < Result.y Then Result := Tri[2];
 If Tri[3].y < Result.y Then Result := Tri[3];
End;
(* End Of LowestPoint *)


Function LowestPoint(Tri:TTriangle3D):TPoint3D;
Begin
 Result.y := MaximumY;
 If Tri[1].y < Result.y Then Result := Tri[1];
 If Tri[2].y < Result.y Then Result := Tri[2];
 If Tri[3].y < Result.y Then Result := Tri[3];
End;
(* End Of LowestPoint *)


Function LowestPoint(Quadix:TQuadix2D):TPoint2D;
Begin
 Result.y := MinimumY;
 If Quadix[1].y > Result.y Then Result := Quadix[1];
 If Quadix[2].y > Result.y Then Result := Quadix[2];
 If Quadix[3].y > Result.y Then Result := Quadix[3];
 If Quadix[4].y > Result.y Then Result := Quadix[4];
End;
(* End Of LowestPoint *)


Function LowestPoint(Quadix:TQuadix3D):TPoint3D;
Begin
 Result.y := MinimumY;
 If Quadix[1].y > Result.y Then Result := Quadix[1];
 If Quadix[2].y > Result.y Then Result := Quadix[2];
 If Quadix[3].y > Result.y Then Result := Quadix[3];
 If Quadix[4].y > Result.y Then Result := Quadix[4];
End;
(* End Of LowestPoint *)


Function Coincident(Pnt1,Pnt2:TPoint2D):Boolean;
Begin
 Result := IsEqual(Pnt1,Pnt2);
End;
(* End Of Coincident - 2D Points *)


Function Coincident(Pnt1,Pnt2:TPoint3D):Boolean;
Begin
 Result := IsEqual(Pnt1,Pnt2);
End;
(* End Of Coincident - 3D Points *)


Function Coincident(Seg1,Seg2:TSegment2D):Boolean;
Begin
 Result := (Coincident(Seg1[1],Seg2[1]) And Coincident(Seg1[2],Seg2[2])) Or
           (Coincident(Seg1[1],Seg2[2]) And Coincident(Seg1[2],Seg2[1]));
End;
(* End Of Coincident - 2D Segments *)


Function Coincident(Seg1,Seg2:TSegment3D):Boolean;
Begin
 Result := (Coincident(Seg1[1],Seg2[1]) And  Coincident(Seg1[2],Seg2[2])) Or
           (Coincident(Seg1[1],Seg2[2]) And  Coincident(Seg1[2],Seg2[1]));
End;
(* End Of Coincident - 3D Segments *)


Function Coincident(Tri1,Tri2:TTriangle2D):Boolean;
Var Flag  : Array [1..3] Of Boolean;
    Count : Integer;
    I,J   : Integer;
Begin
 Count := 0;
 For I:= 1 to 3 Do Flag[I] := False;
 For I:= 1 To 3 Do
  Begin
   For J:= 1 To 3 Do
    If Not Flag[I] Then
     If Coincident(Tri1[i],Tri2[j]) Then
      Begin
       Inc(Count);
       Flag[I]:=True;
       Break;
      End;
  End;
 Result := (Count = 3);
End;
(* End Of Coincident - 2D Triangles *)


Function Coincident(Tri1,Tri2:TTriangle3D):Boolean;
Var Flag  : Array [1..3] Of Boolean;
    Count : Integer;
    I,J   : Integer;
Begin
 Count := 0;
 For I:= 1 to 3 Do Flag[I] := False;
 For I:= 1 To 3 Do
  Begin
   For J:= 1 To 3 Do
    If Not Flag[I] Then
     If Coincident(Tri1[i],Tri2[j]) Then
      Begin
       Inc(Count);
       Flag[I]:=True;
       Break;
      End;
  End;
 Result := (Count = 3);
End;
(* End Of Coincident - 3D Triangles *)


Function Coincident(Rect1,Rect2:TRectangle):Boolean;
Begin
 Result := Coincident(Rect1[1],Rect2[1]) And
           Coincident(Rect1[2],Rect2[2]);
End;
(* End Of Coincident - Rectangles *)


Function Coincident(Quad1,Quad2:TQuadix2D):Boolean;
Var Flag  : Array [1..4] Of Boolean;
    Count : Integer;
    I,J   : Integer;
Begin
 Result := False;
 If ConvexQuadix(Quad1) <> ConvexQuadix(Quad2) Then Exit;
 Count := 0;
 For I:= 1 to 4 Do Flag[I] := False;
 For I:= 1 To 4 Do
  Begin
   For J:= 1 To 4 Do
    If Not Flag[I] Then
     If Coincident(Quad1[i],Quad2[j]) Then
      Begin
       Inc(Count);
       Flag[I]:=True;
       Break;
      End;
  End;
 Result := (Count = 4);
End;
(* End Of Coincident - 2D Quadii *)


Function Coincident(Quad1,Quad2:TQuadix3D):Boolean;
Begin
 Result := False;
End;
(* End Of Coincident - 3D Quadii *)


Function Coincident(Cir1,Cir2:TCircle):Boolean;
Begin
 Result := IsEqual(Cir1.x      , Cir2.x) And
           IsEqual(Cir1.y      , Cir2.y) And
           IsEqual(Cir1.Radius , Cir2.Radius);
End;
(* End Of Coincident - Circles *)


Function Coincident(Sphr1,Sphr2:TSphere):Boolean;
Begin
 Result := IsEqual(Sphr1.x      , Sphr2.x) And
           IsEqual(Sphr1.y      , Sphr2.y) And
           IsEqual(Sphr1.z      , Sphr2.z) And
           IsEqual(Sphr1.Radius , Sphr2.Radius);
End;
(* End Of Coincident - Spheres *)


Procedure PerpendicularPntToSegment(x1,y1,x2,y2,Px,Py:TJmFloat; Var Nx,Ny:TJmFloat);
Var R  : TJmFloat;
    Dx : TJmFloat;
    Dy : TJmFloat;
Begin
 Dx := x2 - x1;
 Dy := y2 - y1;
 R  := ((Px-x1)*Dx+(Py-y1)*Dy)/Sqr(Dx*Dx+Dy*Dy);
 Nx := x1 + R*Dx;
 Ny := y1 + R*Dy;
End;
(* End PerpendicularPntSegment *)


Function  PerpendicularPntToSegment(Seg:TSegment2D; Pnt:TPoint2D):TPoint2D;
Begin
 PerpendicularPntToSegment(Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y,Pnt.x,Pnt.y,Result.x,Result.y);
End;
(* End PerpendicularPntSegment *)


Function PntToSegmentDistance(Px,Py,x1,y1,x2,y2:TJmFloat):TJmFloat;
Var Ratio : TJmFloat;
    Dx    : TJmFloat;
    Dy    : TJmFloat;
Begin
 If IsEqual(x1,x2) And IsEqual(y1,y2) Then
  Begin
   Result := Distance(Px,Py,x1,y1);
  End
  Else
   Begin
    Dx    := x2 - x1;
    Dy    := y2 - y1;
    Ratio := ((Px-x1)*Dx + (Py-y1)*Dy) / (Dx*Dx+Dy*Dy);
    If Ratio < 0 Then Result := Distance(Px,Py,x1,y1)
     Else
      If Ratio > 1 Then Result := Distance(Px,Py,x2,y2)
       Else
        Result := Distance(Px,Py,(1-Ratio)*x1+Ratio*x2,(1-Ratio)*y1+Ratio*y2);
   End;
End;
(* End PntToSegmentDistance *)


Function PntToSegmentDistance(Pnt:TPoint2D; Seg:TSegment2D):TJmFloat;
Begin
 Result := PntToSegmentDistance(Pnt.x, Pnt.y,Seg[1].x,Seg[1].y,Seg[2].x,Seg[2].y);
End;
(* End PntToSegmentDistance *)


Function SegmentsParallel(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;
Begin
 Result := IsEqual(((y1-y2)*(x1-x2)),((y3-y4)*(x3-x4)));
End;
(* End Of SegmentsParallel *)


Function SegmentsParallel(Pnt1,Pnt2,Pnt3,Pnt4:TPoint2D):Boolean;
Begin
 Result := SegmentsParallel(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Pnt4.x,Pnt4.y);
End;
(* End Of SegmentsParallel *)


Function SegmentsParallel(Seg1,Seg2:TSegment2D):Boolean;
Begin
 Result := SegmentsParallel(Seg1[1].x,Seg1[1].y,Seg1[2].x,Seg1[2].y,Seg2[1].x,Seg2[1].y,Seg2[2].x,Seg2[2].y);
End;
(* End Of SegmentsParallel *)


Function SegmentsParallel(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean;
Var Dx1,Dx2 : TJmFloat;
    Dy1,Dy2 : TJmFloat;
    Dz1,Dz2 : TJmFloat;
Begin

 {
    Theory:
    If the gradients in the following planes x-y, y-z, z-x are equal then it can be
    said that the segments are parallel in 3D, However as of yet I haven't been able
    to prove this "mathematically".

    Worst case scenario: 6 floating point divisions and 9 floating point subtractions
 }

 Result := False;

  {
     There is a division-by-zero problem that needs attention.
     My initial solution to the problem is to check divisor of the divisions.
  }


 Dx1 := x1-x2;
 Dx2 := x3-x4;

 //If (IsEqual(dx1,0.0) Or IsEqual(dx2,0.0)) And NotEqual(dx1,dx2) Then Exit;

 Dy1 := y1-y2;
 Dy2 := y3-y4;

 //If (IsEqual(dy1,0.0) Or IsEqual(dy2,0.0)) And NotEqual(dy1,dy2) Then Exit;

 Dz1 := z1-z2;
 Dz2 := z3-z4;

 //If (IsEqual(dy1,0.0) Or IsEqual(dy2,0.0)) And NotEqual(dy1,dy2) Then Exit;


 If NotEqual(Dy1/Dx1,Dy2/Dx2) Then Exit;
 If NotEqual(Dz1/Dy1,Dz2/Dy2) Then Exit;
 If NotEqual(Dx1/Dz1,Dx2/Dz2) Then Exit;

 Result := True;
End;
(* End Of SegmentsParallel*)


Function SegmentsParallel(Pnt1,Pnt2,Pnt3,Pnt4:TPoint3D):Boolean;
Begin
 Result:= SegmentsParallel(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z,Pnt4.x,Pnt4.y,Pnt4.z)
End;
(* End Of SegmentsParallel *)


Function SegmentsParallel(Seg1,Seg2:TSegment3D):Boolean;
Begin
 Result:= SegmentsParallel(Seg1[1],Seg1[2],Seg2[1],Seg2[2]);
End;
(* End Of SegmentsParallel *)


Function SegmentsPerpendicular(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;
Begin
 Result:= IsEqual((y2-y1)*(x3-x4),(y4-y3)*(x2-x1)*-1);
End;
(* End Of SegmentsPerpendicular *)


Function SegmentsPerpendicular(Ln1,Ln2:TLine2D):Boolean;
Begin
 Result:= SegmentsParallel(Ln1[1].x,Ln1[1].y,Ln1[2].x,Ln1[2].y,Ln2[1].x,Ln2[1].y,Ln2[2].x,Ln2[2].y);
End;
(* End Of SegmentsPerpendicular *)


Function SegmentsPerpendicular(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):Boolean;
Var Dx1,Dx2 : TJmFloat;
    Dy1,Dy2 : TJmFloat;
    Dz1,Dz2 : TJmFloat;
Begin
 {
    The dot product of the vector forms of the segments will be
    0 if the segments are perpendicular
 }

 Dx1 := x1 - x2;
 Dx2 := x3 - x4;

 Dy1 := y1 - y2;
 Dy2 := y3 - y4;

 Dz1 := z1 - z2;
 Dz2 := z3 - z4;

 Result := IsEqual((Dx1*Dx2)+(Dy1*Dy2)+(Dz1*Dz2),0)
End;
(* End Of *)


Function SegmentsPerpendicular(Ln1,Ln2:TLine3D):Boolean;
Begin
 Result := SegmentsPerpendicular(Ln1[1].x,Ln1[1].y,Ln1[1].z,Ln1[2].x,Ln1[2].y,Ln1[2].z,Ln2[1].x,Ln2[1].y,Ln2[1].z,Ln2[2].x,Ln2[2].y,Ln2[2].z);
End;
(* End Of SegmentsPerpendicular *)


Procedure SetPlane(xh,xl,yh,yl:TJmFloat);
Begin
End;
(* End Of *)


Procedure SetPlane(Pnt1,Pnt2:TPoint2D);
Begin
End;
(* End Of *)


Procedure SetPlane(Rec:TRectangle);
Begin
End;
(* End Of *)


Function RectangleIntersect(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;
Begin
 Result := ((x1 <= x4) And (x2 <= x3) And (y1 <= y4) And (y2 <= y3));
End;
(* End Of RectangleIntersect *)


Function RectangleIntersect(Rec1,Rec2:TRectangle):Boolean;
Begin
 Result := RectangleIntersect(Rec1[1].x,Rec1[1].y,Rec1[2].x,Rec1[2].y,Rec2[1].x,Rec2[1].y,Rec2[2].x,Rec2[2].y);
End;
(* End Of RectangleIntersect *)


Function Intersect(Cir1,Cir2:TCircle):Boolean;
Begin
 Result := (LayDistance(Cir1.x,Cir1.y,Cir2.x,Cir2.y) <= (Cir1.Radius+Cir2.Radius));
End;
(* End Of CircleIntersect *)


Function CircleInCircle(Cir1,Cir2:TCircle):Boolean;
Begin
 Result := (PntInCircle(Cir1.x,Cir1.y,Cir2) And (Cir1.Radius < Cir2.Radius));
End;
(* End Of CircleInCircle *)


Function IsTangent(Seg:TSegment2D; Cir:TCircle):Boolean;
Var rSqr,drSqr,dSqr : TJmFloat;
Begin
 Seg   := Translate(-Cir.x,-Cir.y,Seg);
 rSqr  := Cir.Radius * Cir.Radius;
 drSqr := LayDistance(Seg);
 dSqr  := Sqr(Seg[1].x*Seg[2].y-Seg[2].x*Seg[1].y);
 Result:= ((rSqr*drSqr-dSqr) = 0);
End;
(* End Of IsTangent *)


Function Distance(x1,y1,x2,y2:TJmFloat):TJmFloat;
Var dx,dy : TJmFloat;
Begin
 dx := (x2-x1);
 dy := (y2-y1);
 Result := Sqrt(dx*dx+dy*dy);
End;
(* End Of Distance *)


Function Distance(Pnt1,Pnt2:TPoint2D):TJmFloat;
Begin
 Result := Distance(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y);
End;
(* End Of Distance *)


Function Distance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;
Var dx,dy,dz : TJmFloat;
Begin
 dx := (x2-x1);
 dy := (y2-y1);
 dz := (z2-z1);
 Result := Sqrt(dx*dx+dy*dy+dz*dz);
End;
(* End Of Distance *)


Function Distance(Pnt1,Pnt2:TPoint3D):TJmFloat;
Begin
 Result := Distance(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z);
End;
(* End Of Distance *)


Function Distance(Line:TLine2D):TJmFloat;
Begin
 Result := Distance(Line[1],Line[2]);
End;
(* End Of Distance *)


Function Distance(Line:TLine3D):TJmFloat;
Begin
 Result := Distance(Line[1],Line[2]);
End;
(* End Of Distance *)


Function Distance(Cir1,Cir2:TCircle):TJmFloat;
Begin
 Result := Distance(Cir1.x,Cir1.y,Cir2.x,Cir2.y);
End;
(* End Of Distance *)


Function LayDistance(x1,y1,x2,y2:TJmFloat):TJmFloat;
Var dx,dy:TJmFloat;
Begin
 dx := (x2-x1);
 dy := (y2-y1);
 Result := dx*dx+dy*dy;
End;
(* End Of LayDistance *)


Function LayDistance(Pnt1,Pnt2:TPoint2D):TJmFloat;
Begin
 Result := LayDistance(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y);
End;
(* End Of LayDistance *)


Function LayDistance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;
Var dx,dy,dz:TJmFloat;
Begin
 dx := (x2-x1);
 dy := (y2-y1);
 dz := (z2-z1);
 Result := dx*dx+dy*dy+dz*dz;
End;
(* End Of LayDistance *)


Function LayDistance(Pnt1,Pnt2:TPoint3D):TJmFloat;
Begin
 Result := LayDistance(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z);
End;
(* End Of LayDistance *)


Function LayDistance(Seg:TSegment2D):TJmFloat;
Begin
 Result := LayDistance(Seg[1],Seg[2]);
End;
(* End Of *)


Function LayDistance(Seg:TSegment3D):TJmFloat;
Begin
 Result := LayDistance(Seg[1],Seg[2]);
End;
(* End Of LayDistance *)


Function LayDistance(Cir1,Cir2:TCircle):TJmFloat;
Begin
 Result := LayDistance(Cir1.x,Cir1.y,Cir2.x,Cir2.y);
End;
(* End Of LayDistance *)


Function ManhattanDistance(x1,y1,x2,y2:TJmFloat):TJmFloat;
Begin
 Result := Abs(x2-x1)+Abs(y2-y1);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(Pnt1,Pnt2:TPoint2D):TJmFloat;
Begin
 Result := ManhattanDistance(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(x1,y1,z1,x2,y2,z2:TJmFloat):TJmFloat;
Begin
 Result := Abs(x2-x1)+Abs(y2-y1)+Abs(z2-z1);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(Pnt1,Pnt2:TPoint3D):TJmFloat;
Begin
 Result := ManhattanDistance(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(Line:TLine2D):TJmFloat;
Begin
 Result := ManhattanDistance(Line[1],Line[2]);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(Line:TLine3D):TJmFloat;
Begin
 Result := ManhattanDistance(Line[1],Line[2]);
End;
(* End Of ManhattanDistance *)


Function ManhattanDistance(Cir1,Cir2:TCircle):TJmFloat;
Begin
 Result := ManhattanDistance(Cir1.x,Cir1.y,Cir2.x,Cir2.y);
End;
(* End Of ManhattanDistance *)


Function TriangleType(x1,y1,x2,y2,x3,y3:TJmFloat):TTriangleType;
Begin
 If IsEquilateralTriangle(x1,y1,x2,y2,x3,y3)    Then Result := Equilateral
  Else
   If IsIsoscelesTriangle(x1,y1,x2,y2,x3,y3)    Then Result := Isosceles
    Else
     If IsRightTriangle(x1,y1,x2,y2,x3,y3)      Then Result := Right
      Else
       If IsScaleneTriangle(x1,y1,x2,y2,x3,y3)  Then Result := Scalene
        Else
         If IsObtuseTriangle(x1,y1,x2,y2,x3,y3) Then Result := Obtuse
          Else
           Result := TUnknown;
End;
(* End Of TriangleType *)


Function TriangleType(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TTriangleType;
Begin
 If IsEquilateralTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3)    Then Result := Equilateral
  Else
   If IsIsoscelesTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3)    Then Result := Isosceles
    Else
     If IsRightTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3)      Then Result := Right
      Else
       If IsScaleneTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3)  Then Result := Scalene
        Else
         If IsObtuseTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3) Then Result := Obtuse
          Else
           Result:= TUnknown;
End;
(* End Of TriangleType *)


Function TriangleType(Pnt1,Pnt2,Pnt3:TPoint2D):TTriangleType;
Begin
 Result := TriangleType(Pnt1,Pnt2,Pnt3);
End;
(* End Of TriangleType *)


Function TriangleType(Pnt1,Pnt2,Pnt3:TPoint3D):TTriangleType;
Begin
 Result := TriangleType(Pnt1,Pnt2,Pnt3);
End;
(* End Of TriangleType *)


Function TriangleType(Tri:TTriangle2D):TTriangleType;
Begin
 Result := TriangleType(Tri[1],Tri[2],Tri[3]);
End;
(* End Of TriangleType *)


Function TriangleType(Tri:TTriangle3D):TTriangleType;
Begin
 Result := TriangleType(Tri[1],Tri[2],Tri[3]);
End;
(* End Of TriangleType *)


Function IsEquilateralTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,x2,y2);
 d2 := LayDistance(x2,y2,x3,y3);
 d3 := LayDistance(x3,y3,x1,y1);
 Result := (IsEqual(d1,d2) And IsEqual(d2,d3));
End;
(* End Of IsEquilateralTriangle *)


Function IsEquilateralTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,z1,x2,y2,z2);
 d2 := LayDistance(x2,y2,z2,x3,y3,z3);
 d3 := LayDistance(x3,y3,z3,x1,y1,z1);
 Result := (IsEqual(d1,d2) And IsEqual(d2,d3));
End;
(* End Of IsEquilateralTriangle *)


Function IsEquilateralTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;
Begin
 Result := IsEquilateralTriangle(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of IsEquilateralTriangle *)


Function IsEquilateralTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;
Begin
 Result := IsEquilateralTriangle(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z);
End;
(* End Of IsEquilateralTriangle *)


Function IsEquilateralTriangle(Tri:TTriangle2D):Boolean;
Begin
 Result := IsEquilateralTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsEquilateralTriangle *)


Function IsEquilateralTriangle(Tri:TTriangle3D):Boolean;
Begin
 Result := IsEquilateralTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsEquilateralTriangle *)


Function IsIsoscelesTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,x2,y2);
 d2 := LayDistance(x2,y2,x3,y3);
 d3 := LayDistance(x3,y3,x1,y1);
 Result :=((IsEqual(d1,d2) Or  IsEqual(d1,d3))  And NotEqual(d2,d3)) Or
          ( IsEqual(d2,d3) And NotEqual(d2,d1));
End;
(* End Of IsIsoscelesTriangle *)


Function IsIsoscelesTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,z1,x2,y2,z2);
 d2 := LayDistance(x2,y2,z2,x3,y3,z3);
 d3 := LayDistance(x3,y3,z3,x1,y1,z1);
 Result :=(
           (IsEqual(d1,d2) Or  IsEqual(d1,d3))  And NotEqual(d2,d3)) Or
           (IsEqual(d2,d3) And NotEqual(d2,d1)
          );
End;
(* End Of IsIsoscelesTriangle *)


Function IsIsoscelesTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;
Begin
 Result := IsIsoscelesTriangle(Pnt1.x, Pnt1.y, Pnt2.x, Pnt2.y, Pnt3.x, Pnt3.y);
End;
(* End Of IsIsoscelesTriangle *)


Function IsIsoscelesTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;
Begin
 Result := IsIsoscelesTriangle(Pnt1.x, Pnt1.y,Pnt1.z, Pnt2.x, Pnt2.y,Pnt2.z, Pnt3.x, Pnt3.y, Pnt3.z);
End;
(* End Of IsIsoscelesTriangle *)


Function IsIsoscelesTriangle(Tri:TTriangle2D):Boolean;
Begin
 Result := IsIsoscelesTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsIsoscelesTriangle *)


Function IsIsoscelesTriangle(Tri:TTriangle3D):Boolean;
Begin
 Result := IsIsoscelesTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of *)


Function IsRightTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := Distance(x1,y1,x2,y2);
 d2 := Distance(x2,y2,x3,y3);
 d3 := Distance(x3,y3,x1,y1);
 Result := (
              IsEqual(d1+d2,d3) Or
              IsEqual(d1+d3,d2) Or
              IsEqual(d3+d2,d1)
           );
End;
(* End Of IsRightTriangle *)


Function IsRightTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := Distance(x1,y1,z1,x2,y2,z2);
 d2 := Distance(x2,y2,z2,x3,y3,z3);
 d3 := Distance(x3,y3,z3,x1,y1,z1);
 Result := (
            IsEqual(d1+d2,d3) Or
            IsEqual(d1+d3,d2) Or
            IsEqual(d3+d2,d1)
           );
End;
(* End Of IsRightTriangle *)


Function IsRightTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;
Begin
 Result := IsRightTriangle(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of IsRightTriangle *)


Function IsRightTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;
Begin
 Result := IsRightTriangle(Pnt1.x,Pnt1.y, Pnt1.z,Pnt2.x,Pnt2.y, Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z);
End;
(* End Of IsRightTriangle *)


Function IsRightTriangle(Tri:TTriangle2D):Boolean;
Begin
 Result := IsRightTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsRightTriangle *)


Function IsRightTriangle(Tri:TTriangle3D):Boolean;
Begin
 Result := IsRightTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsRightTriangle *)


Function IsScaleneTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,x2,y2);
 d2 := LayDistance(x2,y2,x3,y3);
 d3 := LayDistance(x3,y3,x1,y1);
 Result := NotEqual(d1,d2) And NotEqual(d2,d3) And NotEqual(d3,d1);
End;
(* End Of IsScaleneTriangle *)


Function IsScaleneTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var d1,d2,d3:TJmFloat;
Begin
 d1 := LayDistance(x1,y1,z1,x2,y2,z2);
 d2 := LayDistance(x2,y2,z2,x3,y3,z3);
 d3 := LayDistance(x3,y3,z3,x1,y1,z1);
 Result := NotEqual(d1,d2) And NotEqual(d2,d3) And NotEqual(d3,d1);
End;
(* End Of IsScaleneTriangle *)


Function IsScaleneTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;
Begin
 Result := IsScaleneTriangle(Pnt1.x, Pnt1.y, Pnt2.x, Pnt2.y, Pnt3.x, Pnt3.y);
End;
(* End Of IsScaleneTriangle *)


Function IsScaleneTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;
Begin
 Result := IsScaleneTriangle(Pnt1.x, Pnt1.y, Pnt1.z, Pnt2.x, Pnt2.y, Pnt2.z, Pnt3.x, Pnt3.y, Pnt3.z);
End;
(* End Of IsScaleneTriangle *)


Function IsScaleneTriangle(Tri:TTriangle2D):Boolean;
Begin
 Result := IsScaleneTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsScaleneTriangle *)


Function IsScaleneTriangle(Tri:TTriangle3D):Boolean;
Begin
 Result := IsScaleneTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsScaleneTriangle *)


Function IsObtuseTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var a1,a2,a3:TJmFloat;
Begin
 a1 := VertexAngle(x1,y1,x2,y2,x3,y3);
 a2 := VertexAngle(x3,y3,x1,y1,x2,y2);
 a3 := VertexAngle(x2,y2,x3,y3,x1,y1);
 Result := (a1 > 90) Or (a2 > 90) Or (a3 > 90);
End;
(* End Of IsObtuseTriangle *)


Function IsObtuseTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):Boolean;
Var a1,a2,a3:TJmFloat;
Begin
 a1 := VertexAngle(x1,y1,z1,x2,y2,z2,x3,y3,z3);
 a2 := VertexAngle(x3,y3,z3,x1,y1,z1,x2,y2,z2);
 a3 := VertexAngle(x2,y2,z2,x3,y3,z3,x1,y1,z1);
 Result := (a1 > 90) Or (a2 > 90) Or (a3 > 90);
End;
(* End Of IsObtuseTriangle *)


Function IsObtuseTriangle(Pnt1,Pnt2,Pnt3:TPoint2D):Boolean;
Begin
 Result := IsObtuseTriangle(Pnt1.x, Pnt1.y, Pnt2.x, Pnt2.y, Pnt3.x, Pnt3.y);
End;
(* End Of IsObtuseTriangle *)


Function IsObtuseTriangle(Pnt1,Pnt2,Pnt3:TPoint3D):Boolean;
Begin
 Result := IsObtuseTriangle(Pnt1.x, Pnt1.y, Pnt1.z, Pnt2.x, Pnt2.y, Pnt2.z, Pnt3.x, Pnt3.y ,Pnt3.z);
End;
(* End Of IsObtuseTriangle *)


Function IsObtuseTriangle(Tri:TTriangle2D):Boolean;
Begin
 Result := IsObtuseTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsObtuseTriangle *)


Function IsObtuseTriangle(Tri:TTriangle3D):Boolean;
Begin
 Result :=IsObtuseTriangle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of IsObtuseTriangle *)


Function PntInTriangle(Px,Py,x1,y1,x2,y2,x3,y3:TJmFloat):Boolean;
Var Or1, Or2, Or3: TJmFloat;
Begin
 Or1 := Orientation(x1,y1,x2,y2,Px,Py);
 Or2 := Orientation(x2,y2,x3,y3,Px,Py);
 Or3 := Orientation(x3,y3,x1,y1,Px,Py);
 Result := (Or1 = Or2) And (Or2 = Or3);
End;
(* End Of PntInTriangle *)


Function PntInTriangle(Pnt:TPoint2D; Tri:TTriangle2D):Boolean;
Begin
 Result := PntInTriangle(Pnt.x,Pnt.y,Tri[1].x,Tri[1].y,
                                     Tri[2].x,Tri[2].y,
                                     Tri[3].x,Tri[3].y);
End;
(* End Of PntInTriangle *)


Function PntInCircle(Px,Py:TJmFloat; Circle:TCircle):Boolean;
Begin
 Result := (LayDistance(Px,Py,Circle.x,Circle.y) <= (Circle.Radius*Circle.Radius));
End;
(* End Of PntInCircle *)


Function PntInCircle(Pnt:TPoint2D; Circle:TCircle):Boolean;
Begin
 Result := PntInCircle(Pnt.x,Pnt.y,Circle);
End;
(* End Of PntInCircle *)


Function TriangleInCircle(Tri:TTriangle2D; Circle:TCircle):Boolean;
Begin
 Result := PntInCircle(Tri[1],Circle) And
           PntInCircle(Tri[2],Circle) And
           PntInCircle(Tri[3],Circle);
End;
(* End Of TriangleInCircle *)


Function TriangleOutsideCircle(Tri:TTriangle2D; Circle:TCircle):Boolean;
Begin
 Result := (Not PntInCircle(Tri[1],Circle)) And
           (Not PntInCircle(Tri[2],Circle)) And
           (Not PntInCircle(Tri[3],Circle));
End;
(* End Of TriangleOutsideCircle *)


Function RectangleInCircle(Rect:TRectangle; Circle:TCircle):Boolean;
Begin
 Result := PntInCircle(Rect[1].x,Rect[1].y,Circle) And
           PntInCircle(Rect[2].x,Rect[2].y,Circle) And
           PntInCircle(Rect[1].x,Rect[2].y,Circle) And
           PntInCircle(Rect[2].x,Rect[1].y,Circle);
End;
(* End Of RectangleInCircle *)


Function RectangleOutsideCircle(Rect:TRectangle; Circle:TCircle):Boolean;
Begin
 Result := (Not PntInCircle(Rect[1].x,Rect[1].y,Circle)) And
           (Not PntInCircle(Rect[2].x,Rect[2].y,Circle)) And
           (Not PntInCircle(Rect[1].x,Rect[2].y,Circle)) And
           (Not PntInCircle(Rect[2].x,Rect[1].y,Circle));
End;
(* End Of RectangleInCircle *)


Function QuadixInCircle(Quad:TQuadix2D; Circle:TCircle):Boolean;
Begin
 Result:= PntInCircle(Quad[1],Circle) And
          PntInCircle(Quad[2],Circle) And
          PntInCircle(Quad[3],Circle) And
          PntInCircle(Quad[4],Circle);
End;
(* End Of QuadixInCircle *)


Function QuadixOutsideCircle(Quad:TQuadix2D; Circle:TCircle):Boolean;
Begin
 Result := (Not PntInCircle(Quad[1],Circle)) And
           (Not PntInCircle(Quad[2],Circle)) And
           (Not PntInCircle(Quad[3],Circle)) And
           (Not PntInCircle(Quad[4],Circle));
End;
(* End Of QuadixInCircle *)


Function PntInRectangle(Px,Py:TJmFloat; x1,y1,x2,y2:TJmFloat):Boolean;
Begin
 Result := (x1 <= Px) And (x2 >= Px) And (y1 <= Py) And (y2 >= Py);
End;
(* End Of PntInRectangle *)


Function PntInRectangle(Pnt:TPoint2D; x1,y1,x2,y2:TJmFloat):Boolean;
Begin
 Result := PntInRectangle(Pnt.x,Pnt.y,x1,y1,x2,y2);
End;
(* End Of PntInRectangle *)


Function PntInRectangle(Px,Py:TJmFloat; Rec:TRectangle):Boolean;
Begin
 Result := PntInRectangle(Px,Py,Rec[1].x,Rec[1].y,Rec[2].x,Rec[2].y);
End;
(* End Of PntInRectangle *)


Function PntInRectangle(Pnt:TPoint2D; Rec:TRectangle):Boolean;
Begin
 Result := PntInRectangle(Pnt.x,Pnt.y,Rec[1].x,Rec[1].y,Rec[2].x,Rec[2].y);
End;
(* End Of PntInRectangle *)


Function TriangleInRectangle(Tri:TTriangle2D; Rec:TRectangle):Boolean;
Begin
 Result := PntInRectangle(Tri[1],Rec) And
           PntInRectangle(Tri[2],Rec) And
           PntInRectangle(Tri[3],Rec);
End;
(* End Of TriangleInRectangle *)

Function TriangleOutsideRectangle(Tri:TTriangle2D; Rec:TRectangle):Boolean;
Begin
 Result := (Not PntInRectangle(Tri[1],Rec)) And
           (Not PntInRectangle(Tri[2],Rec)) And
           (Not PntInRectangle(Tri[3],Rec));
End;
(* End Of TriangleInRectangle *)


Function QuadixInRectangle(Quad:TQuadix2D; Rec:TRectangle):Boolean;
Begin
 Result := PntInRectangle(Quad[1],Rec) And
           PntInRectangle(Quad[2],Rec) And
           PntInRectangle(Quad[3],Rec) And
           PntInRectangle(Quad[4],Rec);
End;
(* End Of QuadixInRectangle *)


Function QuadixOutsideRectangle(Quad:TQuadix2D; Rec:TRectangle):Boolean;
Begin
 Result := (Not PntInRectangle(Quad[1],Rec)) And
           (Not PntInRectangle(Quad[2],Rec)) And
           (Not PntInRectangle(Quad[3],Rec)) And
           (Not PntInRectangle(Quad[4],Rec));
End;
(* End Of QuadixOutsideRectangle *)


Function PntInQuadix(Px,Py,x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):Boolean;
Var Or1, Or2, Or3, Or4: TJmFloat;
Begin

 Or1 := Orientation(x1,y1,x2,y2,Px,Py);
 Or2 := Orientation(x2,y2,x3,y3,Px,Py);
 Or3 := Orientation(x3,y3,x4,y4,Px,Py);
 Or4 := Orientation(x4,y4,x1,y1,Px,Py);

 Result:= (Or1 = Or2) And (Or2 = Or3) And (Or3 = Or4);

End;
(* End Of PntInQuadix *)


Function PntInQuadix(Pnt,Pnt1,Pnt2,Pnt3,Pnt4: TPoint2D):Boolean;
Begin
 Result := PntInQuadix(Pnt.x,Pnt.y,Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Pnt4.x,Pnt4.y);
End;
(* End Of PntInQuadix *)


Function PntInQuadix(Pnt:TPoint2D; Quad:TQuadix2D):Boolean;
Begin
 Result := PntInQuadix(Pnt,Quad[1],Quad[2],Quad[3],Quad[4]);
End;
(* End Of PntInQuadix *)


Function TriangleInQuadix(Tri:TTriangle2D; Quad:TQuadix2D):Boolean;
Begin
 Result := PntInQuadix(Tri[1],Quad) And
           PntInQuadix(Tri[2],Quad) And
           PntInQuadix(Tri[3],Quad);
End;
(* End Of TriangleInQuadix *)


Function TriangleOutsideQuadix(Tri:TTriangle2D; Quad:TQuadix2D):Boolean;
Begin
 Result := (Not PntInQuadix(Tri[1],Quad)) And
           (Not PntInQuadix(Tri[2],Quad)) And
           (Not PntInQuadix(Tri[3],Quad));
End;
(* End Of TriangleInQuadix *)


Function PntInSphere(x,y,z: TJmFloat; Sphere:TSphere):Boolean;
Begin
 Result := (LayDistance(x,y,z,Sphere.z,Sphere.y,Sphere.z) <= (Sphere.Radius*Sphere.Radius));
End;
(* End Of PntInSphere *)


Function PntInSphere(Pnt3D:TPoint3D; Sphere:TSphere):Boolean;
Begin
 Result := PntInSphere(Pnt3D.x,Pnt3D.y,Pnt3D.z,Sphere);
End;
(* End Of PntInSphere *)


Function PntOnSphere(Pnt3D:TPoint3D; Sphere:TSphere):Boolean;
Begin
 Result := IsEqual(LayDistance(Pnt3D.x,Pnt3D.y,Pnt3D.z,Sphere.z,Sphere.y,Sphere.z),(Sphere.Radius*Sphere.Radius));
End;
(* End Of PntOnSphere *)


Function PolyhedronInSphere(Poly:TPolyhedron; Sphere:TSphere):TInclusion;
Var I,J    : Integer;
  Count    : Integer;
  RealCount: Integer;
Begin
 RealCount:=0;
 Count    :=0;
 For I := 0 To Length(Poly)-1 Do
  Begin
   Inc(RealCount,Length(Poly[I]));
   For J := 0 To Length(Poly[I])-1 Do If PntInSphere(Poly[I][J],Sphere) Then Inc(Count);
  End;
 Result:=Partially;
 If Count = 0 Then Result:= Outside
  Else
   If Count = RealCount Then Result:= Fully;
End;
(* End Of PolyhedronInSphere *)


Function GeometricSpan(Pnt: Array Of TPoint2D):TJmFloat;
Var TempDist : TJmFloat;
    I,J      : Integer;
Begin
 Result := -1;
 For I:= 0 To Length(Pnt)-2 Do
  Begin
   For J:= (I+1) To Length(Pnt)-1 Do
    Begin
     TempDist := LayDistance(Pnt[I],Pnt[J]);
     If TempDist > Result Then Result := TempDist;
    End;
  End;
 Result := Sqrt(Result);
End;
(* End Of 2D Geometric Span *)


Function GeometricSpan(Pnt: Array Of TPoint3D):TJmFloat;
Var TempDist : TJmFloat;
    I,J      : Integer;
Begin
 Result := -1;
 For I:= 0 To Length(Pnt)-2 Do
  Begin
   For J:= (I+1) To Length(Pnt)-1 Do
    Begin
     TempDist := LayDistance(Pnt[I],Pnt[J]);
     If TempDist > Result Then Result := TempDist;
    End;
  End;
 Result := Sqrt(Result);
End;
(* End Of 3D Geometric Span *)


Procedure CreateEquilateralTriangle(x1,y1,x2,y2:TJmFloat; Var x3,y3:TJmFloat);
Const Sin60 = 0.86602540378443864676372317075294;
Const Cos60 = 0.50000000000000000000000000000000;
Begin
 { Translate for x1,y1 to be origin }
 x2   := x2-x1;
 y2   := y2-y1;
 { Rotate 60 degrees and translate back }
 x3 := ((x2*Cos60) - (y2*Sin60))+x1;
 y3 := ((y2*Cos60) + (x2*Sin60))+y1;
End;
(* End Of Create Equilateral Triangle *)


Procedure CreateEquilateralTriangle(Pnt1,Pnt2:TPoint2D; Var Pnt3:TPoint2D);
Begin
 CreateEquilateralTriangle(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y);
End;
(* End Of Create Equilateral Triangle *)


Procedure TorricelliPoint(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);
Var
 OETx1 : TJmFloat;
 OETy1 : TJmFloat;
 OETx2 : TJmFloat;
 OETy2 : TJmFloat;
Begin
 {
    Proven by some guy, the theory goes, if the triangle has an
    angle of 120 degrees or more the toricelli point lies at the vertex.
    Otherwise the point a which the Simpson lines intersect is the optimal
    solution.
    To find an intersection in 2D, all that is needed is 2 lines, hence
    not all three of the simpson lines where calculated.
 }
 If VertexAngle(x1,y1,x2,y2,x3,y3) >= 120.0 Then
  Begin
   Px := x2;
   Py := y2;
   Exit;
  End
  Else
   If VertexAngle(x3,y3,x1,y1,x2,y2) >= 120.0 Then
    Begin
     Px := x1;
     Py := y1;
     Exit;
    End
    Else
     If VertexAngle(x2,y2,x3,y3,x1,y1) >= 120.0 Then
      Begin
       Px := x3;
       Py := y3;
       Exit;
      End
      Else
       Begin
        If Orientation(x1,y1,x2,y2,x3,y3) = RightHand Then
         Begin
          CreateEquilateralTriangle(x1,y1,x2,y2,OETx1,OETy1);
          CreateEquilateralTriangle(x2,y2,x3,y3,OETx2,OETy2);
         End
         Else
          Begin
           CreateEquilateralTriangle(x2,y2,x1,y1,OETx1,OETy1);
           CreateEquilateralTriangle(x3,y3,x2,y2,OETx2,OETy2);
          End;
        IntersectPoint(OETx1,OETy1,x3,y3,OETx2,OETy2,x1,y1,Px,Py);
       End;
End;
(* End Of Create Torricelli Point *)


Function TorricelliPoint(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;
Begin
 TorricelliPoint(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Result.x,Result.y);
End;
(* End Of Create Torricelli Point *)


Function TorricelliPoint(Tri:TTriangle2D):TPoint2D;
Begin
 Result := TorricelliPoint(Tri[1],Tri[2],Tri[3]);
End;
(* End Of Create Torricelli Point *)


Procedure Incenter(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);
Var
 Perim  : TJmFloat;
 Side12 : TJmFloat;
 Side23 : TJmFloat;
 Side31 : TJmFloat;
Begin
 Side12 := Distance(x1,y1,x2,y2);
 Side23 := Distance(x2,y2,x3,y3);
 Side31 := Distance(x3,y3,x1,y1);

 { using Heron's S=UR }
 Perim  := 1/(Side12+Side23+Side31);
 Px     := (Side23*x1+Side31*x2+Side12*x3)*Perim;
 Py     := (Side23*y1+Side31*y2+Side12*y3)*Perim;
End;
(* End Of Incenter *)


Function Incenter(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;
Begin
 Incenter(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Result.x,Result.y);
End;
(* End Of Incenter *)


Function Incenter(Tri:TTriangle2D):TPoint2D;
Begin
 Incenter(Tri[1].x,Tri[1].y,Tri[2].x,Tri[2].y,Tri[3].x,Tri[3].y,Result.x,Result.y);
End;
(* End Of Incenter *)


Procedure Circumcenter(x1,y1,x2,y2,x3,y3:TJmFloat; Var Px,Py:TJmFloat);
Var A,C,B,D,E,F,G:TJmFloat;
Begin
 A := x2 - x1;
 B := y2 - y1;
 C := x3 - x1;
 D := y3 - y1;
 E := A*(x1+x2)+B*(y1+y2);
 F := C*(x1+x3)+D*(y1+y3);
 G := 2.0*(A*(y3-y2)-B*(x3-x2));
 If G = 0 Then Exit;
 Px:=(D*E - B*F)/G;
 Py:=(A*F - C*E)/G;
End;
(* End Of Circumcenter *)


Function Circumcenter(Pnt1,Pnt2,Pnt3:TPoint2D):TPoint2D;
Begin
 Circumcenter(Pnt1.x,Pnt1.y,Pnt2.x,Pnt2.y,Pnt3.x,Pnt3.y,Result.x,Result.y);
End;
(* End Of Circumcenter *)


Function Circumcenter(Tri:TTriangle2D):TPoint2D;
Begin
 Circumcenter(Tri[1].x,Tri[1].y,Tri[2].x,Tri[2].y,Tri[3].x,Tri[3].y,Result.x,Result.y);
End;
(* End Of Circumcenter *)


Function TriangleCircumCircle(P1,P2,P3:TPoint2D):TCircle;
Begin
 Circumcenter(P1.x,P1.y,P2.x,P2.y,P3.x,P3.y,Result.x,Result.y);
 Result.Radius:=Distance(P1.x,P1.y,Result.x,Result.y);
End;
(* End Of TriangleCircumCircle *)


Function TriangleCircumCircle(Tri:TTriangle2D):TCircle;
Begin
 Result := TriangleCircumCircle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of TriangleCircumCircle *)


Function InscribedCircle(P1,P2,P3:TPoint2D):TCircle;
Var Perim    :TJmFloat;
    Side12   :TJmFloat;
    Side23   :TJmFloat;
    Side31   :TJmFloat;
Begin
 Side12:=Distance(P1,P2);
 Side23:=Distance(P2,P3);
 Side31:=Distance(P3,P1);

 { Using Heron's S=UR }
 perim         := 1/(Side12+Side23+Side31);
 Result.x      := (Side23*P1.x+Side31*P2.x+Side12*P3.x)*Perim;
 Result.y      := (Side23*P1.y+Side31*P2.y+Side12*P3.y)*Perim;
 Result.Radius := 0.5*sqrt((-Side12+Side23+Side31)*(Side12-Side23+Side31)*(Side12+Side23-Side31)*Perim);
End;
(* End Of InscribedCircle *)


Function InscribedCircle(Tri:TTriangle2D):TCircle;
Begin
 Result := InscribedCircle(Tri[1],Tri[2],Tri[3]);
End;
(* End Of InscribedCircle *)


Function SegmentMidPoint(P1,P2:TPoint2D):TPoint2D;
Begin
 Result.x := (P1.x-P2.x)*0.5;
 Result.y := (P1.y-P2.y)*0.5;
End;
(* End Of SegmentMidPoint *)


Function SegmentMidPoint(Seg:TSegment2D):TPoint2D;
Begin
 Result := SegmentMidPoint(Seg[1],Seg[2]);
End;
(* End Of SegmentMidPoint *)


Function SegmentMidPoint(P1,P2:TPoint3D):TPoint3D;
Begin
 Result.x := (P1.x-P2.x)*0.5;
 Result.y := (P1.y-P2.y)*0.5;
 Result.z := (P1.z-P2.z)*0.5;
End;
(* End Of SegmentMidPoint *)


Function SegmentMidPoint(Seg:TSegment3D):TPoint3D;
Begin
 Result := SegmentMidPoint(Seg[1],Seg[2]);
End;
(* End Of SegmentMidPoint *)


Function OrthoCenter(x1,y1,x2,y2,x3,y3:TJmFloat):TPoint2D;
Begin
End;
(* End Of OrthoCenter *)


Function OrthoCenter(Pnt1,Pnt2,CPnt:TPoint2D):TPoint2D;
Begin
End;
(* End Of OrthoCenter *)


Function OrthoCenter(Ln1,Ln2,Ln3:TLine2D):TPoint2D;
Begin
End;
(* End Of OrthoCenter *)


Function OrthoCenter(Tri:TTriangle2D):TPoint2D;
Begin
End;
(* End Of OrthoCenter *)


Function PolygonCentroid(Polygon :TPolygon2D):TPoint2D;
Var I: Integer;
Begin
 Result.x := 0;
 Result.y := 0;
 For I:= 0 To Length(Polygon)-1 Do
  Begin
   Result.x := Result.x + Polygon[I].x;
   Result.y := Result.y + Polygon[I].y;
  End;
 Result.x := Result.x / Length(Polygon);
 Result.y := Result.y / Length(Polygon);
End;
(* End Of PolygonCentroid *)


Function PolygonCentroid(Polygon : Array Of TPoint3D):TPoint3D;
Var I : Integer;
Begin
 Result.x := 0;
 Result.y := 0;
 Result.z := 0;
 For I:= 0 To Length(Polygon)-1 Do
  Begin
   Result.x := Result.x + Polygon[I].x;
   Result.y := Result.y + Polygon[I].y;
   Result.z := Result.z + Polygon[I].z;
  End;
 Result.x := Result.x / Length(Polygon);
 Result.y := Result.y / Length(Polygon);
 Result.z := Result.z / Length(Polygon);
End;
(* End Of PolygonCentroid *)


Function PolygonSegmentIntersect(Ln:TLine2D; Poly: TPolygon2D):Boolean;
Var I : Integer;
Begin
 Result := False;
 For I := 0 To Length(Poly)-1 Do
  If Intersect(Ln[1],Ln[2],Poly[I],Poly[(i+1) Mod Length(Poly)]) Then
   Begin
    Result := True;
    Break;
   End;
End;
(* End Of PolygonSegmentIntersect *)


Function PolygonInPolygon(Poly1,Poly2: TPolygon2D):Boolean;
Begin
 Result := False;
End;
(* End Of PolygonInPolygon *)


Function PolygonIntersect(Poly1,Poly2: TPolygon2D):Boolean;
Var I,J:Integer;
Begin
 Result := False;
 For I := 0 To Length(Poly1)-1 Do
  Begin
   For J := 0 To Length(Poly2)-1 Do
    If Intersect(Poly1[I],Poly1[(I+1) Mod Length(Poly1)],Poly2[J],Poly2[(J+1) Mod Length(Poly2)]) Then
     Begin
      Result := True;
      Break;
     End;
  End;
End;
(* End Of PolygonIntersect *)


Function PntInConvexPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;
Var I   : Integer;
    Orin: TJmFloat;
Begin
 Result := True;
 Orin   := Orientation(Poly[0],Poly[1],Px,Py);
 For I := 0 to Length(Poly)-1 do
  If Orin <> Orientation(Poly[I].x,Poly[I].y,Poly[(I+1) Mod Length(Poly)].x,Poly[(I+1) Mod Length(Poly)].y,Px,Py) Then
   Begin
    Result := False;
    Break;
   End;
End;
(* End Of PntInConvexPolygon *)


Function PntInConvexPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;
Begin
 Result := PntInConvexPolygon(Pnt.x,Pnt.y,Poly);
End;
(* End Of PntInConvexPolygon *)


Function PntInConcavePolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;
Begin
 Result := False;
End;
(* End Of PntInConcavePolygon *)


Function PntInConcavePolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;
Begin
 Result := PntInConcavePolygon(Pnt.x,Pnt.y,Poly);
End;
(* End Of PntInConcavePolygon *)


Function PntOnPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;
Var I  : Integer;
Begin
 Result := True;
 For I:= 0 To Length(Poly)-1 Do
  If IsPntCollinear(Poly[I].x, Poly[I].y, Poly[(I+1) Mod Length(Poly)].x,Poly[(I+1) Mod Length(Poly)].y, Px, Py) Then Exit;
 Result := False;
End;
(* End Of PntOnPolygon *)


Function PntOnPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;
Begin
 Result:=PntOnPolygon(Pnt.x,Pnt.y,Poly);
End;
(* End Of PntOnPolygon *)


Function PntInPolygon(Px,Py,FRx,FRy:TJmFloat; Poly: TPolygon2D):Boolean;
Var I            : LongInt;
    IntersectCnt : LongInt;
Begin
 {
   The variables FRx,FRy represent a point to the very far right of the polygon.
   this point is used to create the segment which will be test for intersections
   along the polygon edges.

   For repeatitive point in polygon test using the same polygon, FRx,FRy need only
   be calculated once before calling PntInPolygon, then re-used again for the other
   tests.

   Computational Cost:
   For an N-Point non-self intersecting polygon, detection of point
   within polygon will at least cost: 20n (-), 2n (+), 8n (*), 2n+1 (mod), 2n+1 (if)
 }

 IntersectCnt := 0;

 For I := 0 to Length(Poly)-1 Do
  Begin
   If Intersect(Poly[I].x,Poly[I].y,Poly[(I+1) Mod Length(Poly)].x,Poly[(I+1) Mod Length(Poly)].y,Px,Py,FRx,FRy) Then Inc(IntersectCnt);
  End;

 {
   If intersection count is 0 then point is in otherwise
   point is outside of polygon.
 }
 Result := ((IntersectCnt And 1) = 1);

End;
(* End PntInPolygon *)


Function PntInPolygon(Px,Py:TJmFloat; Poly: TPolygon2D):Boolean;
Var FRx,FRy : TJmFloat;
    I       : LongInt;
Begin
 FRx := MinimumX;
 FRy := MinimumY;
 For I := 0 to Length(Poly)-1 Do
  Begin
   If FRx < Poly[i].x Then FRx := Poly[i].x;
   If FRy < Poly[i].y Then FRy := Poly[i].y;
  End;
 Result := PntInPolygon(Px,Py,FRx,FRy,Poly);
End;
(* End PntInPolygon *)


Function PntInPolygon(Pnt:TPoint2D; Poly: TPolygon2D):Boolean;
Begin
 Result := PntInPolygon(Pnt.x,Pnt.y,Poly);
End;
(* End PntInPolygon *)


Function ConvexQuadix(Quad:TQuadix2D):Boolean;
Var Orin: TJmFloat;
Begin
 Result := False;
 Orin   := Orientation(Quad[1],Quad[3],Quad[2]);
 If Orin <> Orientation(Quad[2],Quad[4],Quad[3]) Then Exit;
 If Orin <> Orientation(Quad[3],Quad[1],Quad[4]) Then Exit;
 If Orin <> Orientation(Quad[4],Quad[2],Quad[1]) Then Exit;
 Result:= True;
End;
(* End Of ConvexQuadix *)


Function ComplexPolygon(Poly: TPolygon2D):Boolean;
Begin
 Result := Not ConvexPolygon(Poly);
End;
(* End Of ComplexPolygon *)


Function SimplePolygon(Poly: TPolygon2D):Boolean;
Begin
 Result := ConvexPolygon(Poly);
End;
(* End Of SimplePolygon *)


Function ConvexPolygon(Poly: TPolygon2D):Boolean;
Var I   : Integer;
    Orin: TJmFloat;
Begin
 Result:= False;
 Orin  := Orientation(Poly[0],Poly[2],Poly[1].x,Poly[1].y);
 For I:= 1 to Length(Poly)-1 do
  If Orin <> Orientation(Poly[I].x,Poly[I].y,Poly[(I+2) Mod Length(Poly)].x,Poly[(I+2) Mod Length(Poly)].y,Poly[2].x,Poly[2].y) Then Exit;
 Result:= True;
End;
(* End Of ConvexPolygon *)


Function ConcavePolygon(Poly: TPolygon2D):Boolean;
Begin
 Result := Not ConvexPolygon(Poly);
End;
(* End Of ConcavePolygon *)


Procedure PolygonConstruction(Poly: TPolygon2D);
Begin
End;
(* End Of *)


Function ConvexHull(Polygon:TPolygon2D):TPolygon2D;
Begin
End;
(* End Of *)


Function ConvexHull(Polyhedron:TPolyhedron):TPolyhedron;
Begin
End;
(* End Of *)


Function RectangularHull(Point: Array Of TPoint2D):TRectangle;
Var MaxX,MaxY,MinX,MinY:TJmFloat;
    I:Integer;
Begin
 MaxX := MinimumX;
 MaxY := MinimumY;
 MinX := MaximumX;
 MinY := MaximumY;
 For I:= 0 to Length(Point)-1 Do
  Begin
   If Point[I].x < MinX Then MinX := Point[I].x;
   If Point[I].x > MaxX Then MaxX := Point[I].x;
   If Point[I].y < MinY Then MinY := Point[I].y;
   If Point[I].y > MaxY Then MaxY := Point[I].y;
  End;
 Result := EquateRectangle(MinX,MinY,MaxX,MaxY);
End;
(* End Of RectangularHull *)


Function RectangularHull(Poly: TPolygon2D):TRectangle;
Var Point : Array Of TPoint2D;
    I     : Integer;
Begin
 SetLength(Point,Length(Poly));
 For I :=  0 to Length(Poly)-1 Do
  Point[I] := Poly[I];
 Result := RectangularHull(Point);
 Point := Nil;
End;
(* End Of RectangularHull *)


Function CircularHull(Poly:TPolygon2D):TCircle;
Var I      : Integer;
    Cen    : TPoint2D;
    LLen   : TJmFloat;
    LayDist: TJmFloat;
Begin
 LLen := -1;
 Cen := PolygonCentroid(Poly);
 For I:= 0 To Length(Poly)-1 Do
  Begin
   LayDist:= LayDistance(Cen,Poly[I]);
   If LayDist > LLen Then LLen:=LayDist;
  End;
 Result.x      := Cen.x;
 Result.y      := Cen.y;
 Result.Radius := LLen;
End;
(* End Of CircularHull *)


Function SphereHull(Poly: Array Of TPoint3D):TSphere;
Var I      : Integer;
    Cen    : TPoint3D;
    LLen   : TJmFloat;
    LayDist: TJmFloat;
Begin
 LLen := -1;
 Cen := PolygonCentroid(Poly);
 For I:= 0 To Length(Poly)-1 Do
  Begin
   LayDist:= LayDistance(Cen,Poly[I]);
   If LayDist > LLen Then LLen:=LayDist;
  End;
 Result.x      := Cen.x;
 Result.y      := Cen.y;
 Result.z      := Cen.z;
 Result.Radius := LLen;
End;
(* End Of SphereHull *)


Function Clip(Seg:TSegment2D; Rec:TRectangle):TSegment2D;
 Const CLIP_LEFT   = 1;
 Const CLIP_RIGHT  = 2;
 Const CLIP_BOTTOM = 4;
 Const CLIP_TOP    = 8;
 Function OutCode(x,y:TJmFloat):Integer;
 Begin
  Result:=0;
  If y < Rec[1].y Then    Result := Result Or CLIP_TOP
   Else
    If y > Rec[2].y Then  Result := Result Or CLIP_BOTTOM;

   If x < Rec[1].x Then   Result := Result Or CLIP_LEFT
    Else
     If x > Rec[2].x Then Result := Result Or CLIP_RIGHT;
 End;
Var
 OCPnt           : Array [1..2] Of Integer;
 I               : Integer;
 L1C,L2C,L3C,L4C : Boolean;
 Dx,Dy           : TJmFloat;
Begin

 L1C      := False;
 L2C      := False;
 L3C      := False;
 L4C      := False;
 OCPnt[1] := OutCode(Seg[1].x,Seg[1].y);
 OCPnt[2] := OutCode(Seg[2].x,Seg[2].y);

 Dx:= (Seg[2].x - Seg[1].x);
 Dy:= (Seg[2].y - Seg[1].y);

 Result := Seg;

 If ((OCPnt[1] Or OcPnt[2]) = 0) Or
     (OCPnt[1] =  OCPnt[2]) Then Exit
  Else
   Begin
    {
      Note: Even though the code may seem complex, at most only 2
            divisions ever occur per segment clip.
    }
    For I:= 1 to 2 Do
     Begin
      If ((OCPnt[I] And CLIP_LEFT) <> 0) And (Not L1C) Then
       Begin
        Seg[I].y := Seg[1].y+Dy*(Rec[1].x-Seg[1].x)/Dx;
        Seg[I].x := Rec[1].x;
        OCPnt[I] := 0;
        L1C      := True;
       End
       Else
        If ((OCPnt[I] And CLIP_TOP) <> 0) And (Not L2C) Then
         Begin
          Seg[I].x := Seg[1].x+Dx*(Rec[1].y-Seg[1].y)/Dy;
          Seg[I].y := Rec[1].y;
          OCPnt[I] := 0;
          L2C      := True;
         End
         Else
          If ((OCPnt[I] And CLIP_RIGHT) <> 0) And (Not L3C) Then
           Begin
            Seg[I].y := Seg[1].y+Dy*(Rec[2].x-Seg[1].x)/Dx;
            Seg[I].x := Rec[2].x;
            OCPnt[I] := 0;
            L3C      := True;
           End
           Else
            If ((OCPnt[I] And CLIP_BOTTOM) <> 0) And (Not L4C) Then
             Begin
              Seg[I].x := Seg[1].x+Dx*(Rec[2].y-Seg[1].y)/Dy;
              Seg[I].y := Rec[2].y;
              OCPnt[I] := 0;
              L4C      := True;
             End;
       End;
     End;
 Result := Seg;
End;
(* End Of Clip *)


Function Clip(Seg:TSegment2D; Tri:TTriangle2D):TSegment2D;
Var Pos :Integer;
Begin
 Pos:=1;

 If Intersect(Seg[1],Seg[2],Tri[1],Tri[2]) Then
  Begin
   Result[Pos] := IntersectPoint(Seg[1],Seg[2],Tri[1],Tri[2]);
   Inc(Pos);
  End;

 If Intersect(Seg[1],Seg[2],Tri[2],Tri[3]) Then
  Begin
   Result[Pos] := IntersectPoint(Seg[1],Seg[2],Tri[2],Tri[3]);
   Inc(Pos);
  End;

 If Intersect(Seg[1],Seg[2],Tri[3],Tri[1])  And (Pos < 3) Then
  Begin
   Result[Pos] := IntersectPoint(Seg[1],Seg[2],Tri[3],Tri[1]);
   Inc(Pos);
  End;

  If Pos = 2 Then
  Begin
   If PntInTriangle(Seg[1],Tri) Then Result[Pos]:= Seg[1]
    Else
     Result[Pos] := Seg[2];
  End;

End;
(* End Of Clip *)


Function Clip(Seg:TSegment2D; Quad:TQuadix2D):TSegment2D;
Var Pos :Integer;
Begin
 Pos:=1;

 If Intersect(Seg[1],Seg[2],Quad[1],Quad[2]) Then
  Begin
   Result[Pos]:= IntersectPoint(Seg[1],Seg[2],Quad[1],Quad[2]);
   Inc(Pos);
  End;

 If Intersect(Seg[1],Seg[2],Quad[2],Quad[3]) Then
  Begin
   Result[Pos]:= IntersectPoint(Seg[1],Seg[2],Quad[2],Quad[3]);
   Inc(Pos);
  End;

 If Intersect(Seg[1],Seg[2],Quad[3],Quad[4]) And (Pos < 3) Then
  Begin
   Result[Pos]:= IntersectPoint(Seg[1],Seg[2],Quad[3],Quad[4]);
   Inc(Pos);
  End;

 If Intersect(Seg[1],Seg[2],Quad[4],Quad[1]) And (Pos < 3) Then
  Begin
   Result[Pos]:= IntersectPoint(Seg[1],Seg[2],Quad[4],Quad[1]);
   Inc(Pos);
  End;

  If Pos = 2 Then
   Begin
    If PntInQuadix(Seg[1],Quad) Then Result[Pos]:= Seg[1]
     Else
      Result[Pos]:= Seg[2];
   End;

End;
(* End Of Clip *)


Function Area(Tri:TTriangle2D):TJmFloat;
Begin
 Result := 0.5*
           (
            (Tri[1].x*(Tri[2].y-Tri[3].y))+
            (Tri[2].x*(Tri[3].y-Tri[1].y))+
            (Tri[3].x*(Tri[1].y-Tri[2].y))
           );
End;
(* End Of Area 2D Triangle *)


Function Area(Tri:TTriangle3D):TJmFloat;
Var Dx1,Dx2  : TJmFloat;
    Dy1,Dy2  : TJmFloat;
    Dz1,Dz2  : TJmFloat;
    Cx,Cy,Cz : TJmFloat;
Begin

 Dx1 := Tri[2].x - Tri[1].x;
 Dy1 := Tri[2].y - Tri[1].y;
 Dz1 := Tri[2].z - Tri[1].z;

 Dx2 := Tri[3].x - Tri[1].x;
 Dy2 := Tri[3].y - Tri[1].y;
 Dz2 := Tri[3].z - Tri[1].z;

 Cx  := Dy1*Dz2- Dy2*Dz1;
 Cy  := Dx2*Dz1- Dx1*Dz2;
 Cz  := Dx1*Dy2- Dx2*Dy1;

 Result := (sqrt(Cx*Cx + Cy*Cy + Cz*Cz)*0.5);
End;
(* End Of Area 3D Triangle *)


Function Area(Quad:TQuadix2D):TJmFloat;
Begin
 Result := 0.5*
           (
            (Quad[1].x*(Quad[2].y-Quad[4].y))+
            (Quad[2].x*(Quad[3].y-Quad[1].y))+
            (Quad[3].x*(Quad[4].y-Quad[2].y))+
            (Quad[4].x*(Quad[1].y-Quad[3].y))
           );
End;
(* End Of Area 2D Qudix *)


Function Area(Quad:TQuadix3D):TJmFloat;
Begin
 Result := (
            Area(EquateTriangle(Quad[1],Quad[2],Quad[3]))+
            Area(EquateTriangle(Quad[3],Quad[4],Quad[1]))
           );
End;
(* End Of Area 3D Quadix *)


Function Area(Rec:TRectangle):TJmFloat;
Begin
 Result:=(Rec[2].x-Rec[1].x)*(Rec[2].y-Rec[1].y);
End;
(* End Of Area *)


Function Area(Cir:TCircle):TJmFloat;
Begin
 Result := PI2*Cir.Radius*Cir.Radius;
End;
(* End Of Area *)


Function Area(Poly:TPolygon2D):TJmFloat;
Var I  :Integer;
Begin
 Result := 0.0;
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Result := Result+(
                      (Poly[i].x*Poly[(i+1) Mod Length(Poly)].y)-
                      (Poly[i].y*Poly[(i+1) Mod Length(Poly)].x)
                     );
  End;
 Result := Result*0.5;
End;
(* End Of Area *)


Function Perimeter(Tri:TTriangle2D):TJmFloat;
Begin
 Result:= Distance(Tri[1],Tri[2])+
          Distance(Tri[2],Tri[3])+
          Distance(Tri[3],Tri[1]);
End;
(* End Of Circumference *)


Function Perimeter(Tri:TTriangle3D):TJmFloat;
Begin
 Result:= Distance(Tri[1],Tri[2])+
          Distance(Tri[2],Tri[3])+
          Distance(Tri[3],Tri[1]);
End;
(* End Of Circumference *)


Function Perimeter(Quad:TQuadix2D):TJmFloat;
Begin
 Result:= Distance(Quad[1],Quad[2])+
          Distance(Quad[2],Quad[3])+
          Distance(Quad[3],Quad[4]);
          Distance(Quad[4],Quad[1]);
End;
(* End Of Circumference *)


Function Perimeter(Quad:TQuadix3D):TJmFloat;
Begin
 Result:= Distance(Quad[1],Quad[2])+
          Distance(Quad[2],Quad[3])+
          Distance(Quad[3],Quad[4]);
          Distance(Quad[4],Quad[1]);
End;
(* End Of Circumference *)


Function Perimeter(Rec:TRectangle):TJmFloat;
Begin
 Result:= 2*((Rec[2].x-Rec[1].x)+(Rec[2].y-Rec[1].y));
End;
(* End Of Circumference *)


Function Perimeter(Cir:TCircle):TJmFloat;
Begin
 Result:= 2*Pi*Cir.Radius;
End;
(* End Of Circumference *)


Function Perimeter(Poly:TPolygon2D):TJmFloat;
Var I : Integer;
Begin
 Result:=0;
 For I:= 0 to Length(Poly)-1 Do Result:=Result+Distance(Poly[I], Poly[(I+1) Mod Length(Poly)]);
End;
(* End Of Circumference *)



Procedure  Rotate(RotAng:TJmFloat; x,y:TJmFloat; Var Nx,Ny:TJmFloat);
Var SinVal:TJmFloat;
    CosVal:TJmFloat;
Begin
 RotAng := RotAng*PIDiv180;
 SinVal := Sin(RotAng);
 CosVal := Cos(RotAng);
 Nx     := x*CosVal - y*SinVal;
 Ny     := y*CosVal + x*SinVal;
End;
(* End Of Rotate Cartesian Point*)


Procedure Rotate(RotAng:TJmFloat; x,y,ox,oy:TJmFloat; Var Nx,Ny:TJmFloat);
Begin
 Rotate(RotAng,x-ox,y-oy,Nx,Ny);
 Nx := Nx+ox;
 Ny := Ny+oy;
End;
(* End Of Rotate Cartesian Point About Origin *)


Function Rotate(RotAng:TJmFloat; Pnt:TPoint2D):TPoint2D;
Begin
 Rotate(RotAng,Pnt.x,Pnt.y,Result.x,Result.y);
End;
(* End Of Rotate Point *)


Function Rotate(RotAng:TJmFloat; Pnt,OPnt:TPoint2D):TPoint2D;
Begin
 Rotate(RotAng,Pnt.x,Pnt.y,OPnt.x,OPnt.y,Result.x,Result.y);
End;
(* End Of Rotate Point About Origin *)


Function Rotate(RotAng:TJmFloat; Seg:TSegment2D):TSegment2D;
Begin
 Result[1] := Rotate(RotAng,Seg[1]);
 Result[2] := Rotate(RotAng,Seg[2]);
End;
(* End Of Rotate Segment*)


Function Rotate(RotAng:TJmFloat; Seg:TSegment2D; OPnt: TPoint2D):TSegment2D;
Begin
 Result[1] := Rotate(RotAng,Seg[1],OPnt);
 Result[2] := Rotate(RotAng,Seg[2],OPnt);
End;
(* End Of Rotate Segment About Origin *)


Function Rotate(RotAng:TJmFloat; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1] := Rotate(RotAng,Tri[1]);
 Result[2] := Rotate(RotAng,Tri[2]);
 Result[3] := Rotate(RotAng,Tri[3]);
End;
(* End Of Rotate 2D Triangle*)


Function Rotate(RotAng:TJmFloat; Tri:TTriangle2D; OPnt:TPoint2D):TTriangle2D;
Begin
 Result[1] := Rotate(RotAng,Tri[1],OPnt);
 Result[2] := Rotate(RotAng,Tri[2],OPnt);
 Result[3] := Rotate(RotAng,Tri[3],OPnt);
End;
(* End Of Rotate 2D Triangle About Origin *)


Function Rotate(RotAng:TJmFloat; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1] := Rotate(RotAng,Quad[1]);
 Result[2] := Rotate(RotAng,Quad[2]);
 Result[3] := Rotate(RotAng,Quad[3]);
 Result[4] := Rotate(RotAng,Quad[4]);
End;
(* End Of Rotate 2D Quadix*)


Function Rotate(RotAng:TJmFloat; Quad:TQuadix2D; OPnt:TPoint2D):TQuadix2D;
Begin
 Result[1] := Rotate(RotAng,Quad[1],OPnt);
 Result[2] := Rotate(RotAng,Quad[2],OPnt);
 Result[3] := Rotate(RotAng,Quad[3],OPnt);
 Result[4] := Rotate(RotAng,Quad[4],OPnt);
End;
(* End Of Rotate 2D Quadix About Origin *)


Function Rotate(RotAng:TJmFloat; Poly:TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := Rotate(RotAng,Poly[I]);
  End;
 Result := Poly;
End;
(* End Of Rotate 2D Polygon *)


Function Rotate(RotAng:TJmFloat; Poly:TPolygon2D; OPnt:TPoint2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := Rotate(RotAng,Poly[I],OPnt);
  End;
 Result := Poly;
End;
(* End Of Rotate 2D Polygon About Origin *)


Procedure Rotate(Rx,Ry,Rz:TJmFloat; x,y,z:TJmFloat; Var Nx,Ny,Nz:TJmFloat);
Var TempX  : TJmFloat;
    TempY  : TJmFloat;
    TempZ  : TJmFloat;
    SinX   : TJmFloat;
    SinY   : TJmFloat;
    SinZ   : TJmFloat;
    CosX   : TJmFloat;
    CosY   : TJmFloat;
    CosZ   : TJmFloat;
    XRadAng: TJmFloat;
    YRadAng: TJmFloat;
    ZRadAng: TJmFloat;
Begin

 XRadAng := Rx*PIDiv180;
 YRadAng := Ry*PIDiv180;
 ZRadAng := Rz*PIDiv180;

 SinX    := Sin(XRadAng);
 SinY    := Sin(YRadAng);
 SinZ    := Sin(ZRadAng);

 CosX    := Cos(XRadAng);
 CosY    := Cos(YRadAng);
 CosZ    := Cos(ZRadAng);

 Tempy   := y*CosY - z*SinY;
 Tempz   := y*SinY + z*CosY;
 Tempx   := x*CosX - Tempz*SinX;

 Nz      := x*SinX     + Tempz*CosX;
 Nx      := Tempx*CosZ - TempY*SinZ;
 Ny      := Tempx*SinZ + TempY*CosZ;

End;
(* End Of *)


Procedure Rotate(Rx,Ry,Rz:TJmFloat; x,y,z,ox,oy,oz:TJmFloat; Var Nx,Ny,Nz:TJmFloat);
Begin
 Rotate(Rx,Ry,Rz,x-ox,y-oy,z-oz,Nx,Ny,Nz);
 Nx := Nx+ox;
 Ny := Ny+oy;
 Nz := Nz+oz;
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Pnt:TPoint3D):TPoint3D;
Begin
 Rotate(Rx,Ry,Rz,Pnt.x,Pnt.y,Pnt.z,Result.x,Result.y,Result.z);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Pnt,OPnt:TPoint3D):TPoint3D;
Begin
 Rotate(Rx,Ry,Rz,Pnt.x,Pnt.y,Pnt.z,OPnt.x,OPnt.y,OPnt.z,Result.x,Result.y,Result.z);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Seg:TSegment3D):TSegment3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Seg[1]);
 Result[2] := Rotate(Rx,Ry,Rz,Seg[2]);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Seg:TSegment3D; OPnt: TPoint3D):TSegment3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Seg[1],OPnt);
 Result[2] := Rotate(Rx,Ry,Rz,Seg[2],OPnt);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Tri:TTriangle3D):TTriangle3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Tri[1]);
 Result[2] := Rotate(Rx,Ry,Rz,Tri[2]);
 Result[3] := Rotate(Rx,Ry,Rz,Tri[3]);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Tri:TTriangle3D; OPnt:TPoint3D):TTriangle3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Tri[1],OPnt);
 Result[2] := Rotate(Rx,Ry,Rz,Tri[2],OPnt);
 Result[3] := Rotate(Rx,Ry,Rz,Tri[3],OPnt);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Quad:TQuadix3D):TQuadix3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Quad[1]);
 Result[2] := Rotate(Rx,Ry,Rz,Quad[2]);
 Result[3] := Rotate(Rx,Ry,Rz,Quad[3]);
 Result[4] := Rotate(Rx,Ry,Rz,Quad[4]);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Quad:TQuadix3D; OPnt:TPoint3D):TQuadix3D;
Begin
 Result[1] := Rotate(Rx,Ry,Rz,Quad[1],OPnt);
 Result[2] := Rotate(Rx,Ry,Rz,Quad[2],OPnt);
 Result[3] := Rotate(Rx,Ry,Rz,Quad[3],OPnt);
 Result[4] := Rotate(Rx,Ry,Rz,Quad[4],OPnt);
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Poly:TPolygon3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := Rotate(Rx,Ry,Rz,Poly[I]);
  End;
 Result := Poly;
End;
(* End Of *)


Function Rotate(Rx,Ry,Rz:TJmFloat; Poly:TPolygon3D; OPnt:TPoint3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := Rotate(Rx,Ry,Rz,Poly[I],OPnt);
  End;
 Result := Poly;
End;
(* End Of *)


Procedure FastRotate(RotAng:Integer; x,y:TJmFloat; Var Nx,Ny:TJmFloat);
Var SinVal:TJmFloat;
    CosVal:TJmFloat;
Begin
 RotAng := RotAng Mod 360;
 SinVal := SinTable[RotAng];
 CosVal := CosTable[RotAng];
 Nx     := x*CosVal - y*SinVal;
 Ny     := y*CosVal + x*SinVal;
End;
(* End Of Fast Rotation *)


Procedure FastRotate(RotAng:Integer; x,y,ox,oy:TJmFloat; Var Nx,Ny:TJmFloat);
Var SinVal:TJmFloat;
    CosVal:TJmFloat;
Begin
 RotAng := RotAng Mod 360;
 SinVal := SinTable[RotAng];
 CosVal := CosTable[RotAng];
 x      := x-ox;
 y      := y-oy;
 Nx     := (x*CosVal - y*SinVal)+ox;
 Ny     := (y*CosVal + x*SinVal)+oy;
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Pnt:TPoint2D):TPoint2D;
Begin
 FastRotate(RotAng,Pnt.x,Pnt.y,Result.x,Result.y);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Pnt,OPnt:TPoint2D):TPoint2D;
Begin
 FastRotate(RotAng,Pnt.x,Pnt.y,OPnt.x,OPnt.y,Result.x,Result.y);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Seg:TSegment2D):TSegment2D;
Begin
 Result[1] := FastRotate(RotAng,Seg[1]);
 Result[2] := FastRotate(RotAng,Seg[2]);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Seg:TSegment2D; OPnt: TPoint2D):TSegment2D;
Begin
 Result[1] := FastRotate(RotAng,Seg[1],OPnt);
 Result[2] := FastRotate(RotAng,Seg[2],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1] := FastRotate(RotAng,Tri[1]);
 Result[2] := FastRotate(RotAng,Tri[2]);
 Result[3] := FastRotate(RotAng,Tri[3]);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Tri:TTriangle2D; OPnt:TPoint2D):TTriangle2D;
Begin
 Result[1] := FastRotate(RotAng,Tri[1],OPnt);
 Result[2] := FastRotate(RotAng,Tri[2],OPnt);
 Result[3] := FastRotate(RotAng,Tri[3],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1] := FastRotate(RotAng,Quad[1]);
 Result[2] := FastRotate(RotAng,Quad[2]);
 Result[3] := FastRotate(RotAng,Quad[3]);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Quad:TQuadix2D; OPnt:TPoint2D):TQuadix2D;
Begin
 Result[1] := FastRotate(RotAng,Quad[1],OPnt);
 Result[2] := FastRotate(RotAng,Quad[2],OPnt);
 Result[3] := FastRotate(RotAng,Quad[3],OPnt);
 Result[4] := FastRotate(RotAng,Quad[4],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Poly:TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Poly[I]:=Rotate(RotAng,Poly[I]);
 Result := Poly;
End;
(* End Of Fast Rotation *)


Function FastRotate(RotAng:Integer; Poly:TPolygon2D; OPnt:TPoint2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Poly[I]:=Rotate(RotAng,Poly[I],OPnt);
 Result := Poly;
End;
(* End Of Fast Rotation *)


Procedure FastRotate(Rx,Ry,Rz:Integer; x,y,z:TJmFloat; Var Nx,Ny,Nz:TJmFloat);
Var TempX  : TJmFloat;
    TempY  : TJmFloat;
    TempZ  : TJmFloat;
    SinX   : TJmFloat;
    SinY   : TJmFloat;
    SinZ   : TJmFloat;
    CosX   : TJmFloat;
    CosY   : TJmFloat;
    CosZ   : TJmFloat;
Begin
 Rx      := Rx Mod 360;
 Ry      := Ry Mod 360;
 Rz      := Rz Mod 360;

 SinX    := SinTable[Rx];
 SinY    := SinTable[Ry];
 SinZ    := SinTable[Rz];

 CosX    := CosTable[Rx];
 CosY    := CosTable[Ry];
 CosZ    := CosTable[Rz];

 Tempy   := y*CosY  - z*SinY;
 Tempz   := y*SinY  + z*CosY;
 Tempx   := x*CosX  - Tempz*SinX;

 Nz      := x*SinX     + Tempz*CosX;
 Nx      := Tempx*CosZ - TempY*SinZ;
 Ny      := Tempx*SinZ + TempY*CosZ;
End;
(* End Of Fast Rotation *)


Procedure FastRotate(Rx,Ry,Rz:Integer; x,y,z,ox,oy,oz:TJmFloat; Var Nx,Ny,Nz:TJmFloat);
Begin
 FastRotate(Rx,Ry,Rz,x-ox,y-oy,z-oz,Nx,Ny,Nz);
 Nx := Nx+ox;
 Ny := Ny+oy;
 Nz := Nz+oz;
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Pnt:TPoint3D):TPoint3D;
Begin
 FastRotate(Rx,Ry,Rz,Pnt.x,Pnt.y,Pnt.z,Result.x,Result.y,Result.z);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Pnt,OPnt:TPoint3D):TPoint3D;
Begin
 FastRotate(Rx,Ry,Rz,Pnt.x,Pnt.y,Pnt.z,OPnt.x,OPnt.y,OPnt.z,Result.x,Result.y,Result.z);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Seg:TSegment3D):TSegment3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Seg[1]);
 Result[2] := FastRotate(Rx,Ry,Rz,Seg[2]);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Seg:TSegment3D; OPnt: TPoint3D):TSegment3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Seg[1],OPnt);
 Result[2] := FastRotate(Rx,Ry,Rz,Seg[2],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Tri:TTriangle3D):TTriangle3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Tri[1]);
 Result[2] := FastRotate(Rx,Ry,Rz,Tri[2]);
 Result[3] := FastRotate(Rx,Ry,Rz,Tri[3]);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Tri:TTriangle3D; OPnt:TPoint3D):TTriangle3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Tri[1],OPnt);
 Result[2] := FastRotate(Rx,Ry,Rz,Tri[2],OPnt);
 Result[3] := FastRotate(Rx,Ry,Rz,Tri[3],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Quad:TQuadix3D):TQuadix3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Quad[1]);
 Result[2] := FastRotate(Rx,Ry,Rz,Quad[2]);
 Result[3] := FastRotate(Rx,Ry,Rz,Quad[3]);
 Result[4] := FastRotate(Rx,Ry,Rz,Quad[4]);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Quad:TQuadix3D; OPnt:TPoint3D):TQuadix3D;
Begin
 Result[1] := FastRotate(Rx,Ry,Rz,Quad[1],OPnt);
 Result[2] := FastRotate(Rx,Ry,Rz,Quad[2],OPnt);
 Result[3] := FastRotate(Rx,Ry,Rz,Quad[3],OPnt);
 Result[4] := FastRotate(Rx,Ry,Rz,Quad[4],OPnt);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Poly:TPolygon3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Poly[I] := FastRotate(Rx,Ry,Rz,Poly[I]);
End;
(* End Of Fast Rotation *)


Function FastRotate(Rx,Ry,Rz:Integer; Poly:TPolygon3D; OPnt:TPoint3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Poly[I] := FastRotate(Rx,Ry,Rz,Poly[I],OPnt);
End;
(* End Of Fast Rotation *)


Function Translate(Dx,Dy:TJmFloat; Pnt:TPoint2D):TPoint2D;
Begin
 Result.x:= Pnt.x + Dx;
 Result.y:= Pnt.y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Ln:TLine2D):TLine2D;
Begin
 Result[1].x := Ln[1].x + Dx;
 Result[1].y := Ln[1].y + Dy;
 Result[2].x := Ln[2].x + Dx;
 Result[2].y := Ln[2].y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Seg:TSegment2D):TSegment2D;
Begin
 Result[1].x := Seg[1].x + Dx;
 Result[1].y := Seg[1].y + Dy;
 Result[2].x := Seg[2].x + Dx;
 Result[2].y := Seg[2].y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1].x := Tri[1].x + Dx;
 Result[1].y := Tri[1].y + Dy;
 Result[2].x := Tri[2].x + Dx;
 Result[2].y := Tri[2].y + Dy;
 Result[3].x := Tri[3].x + Dx;
 Result[3].y := Tri[3].y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1].x := Quad[1].x + Dx;
 Result[1].y := Quad[1].y + Dy;
 Result[2].x := Quad[2].x + Dx;
 Result[2].y := Quad[2].y + Dy;
 Result[3].x := Quad[3].x + Dx;
 Result[3].y := Quad[3].y + Dy;
 Result[4].x := Quad[4].x + Dx;
 Result[4].y := Quad[4].y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Rec:TRectangle):TRectangle;
Begin
 Result[1].x := Rec[1].x + Dx;
 Result[1].y := Rec[1].y + Dy;
 Result[2].x := Rec[2].x + Dx;
 Result[2].y := Rec[2].y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Cir:TCircle):TCircle;
Begin
 Result.x := Cir.x + Dx;
 Result.y := Cir.y + Dy;
End;
(* End Of Translate *)


Function Translate(Dx,Dy:TJmFloat; Poly: TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 to Length(Poly)-1 do
  Begin
   Result[I].x := Poly[I].x + Dx;
   Result[I].y := Poly[I].y + Dy;
  End;
End;
(* End Of Translate *)


Function Translate(Pnt:TPoint2D; Poly: TPolygon2D):TPolygon2D;
Begin
 Result:= Translate(Pnt.x,Pnt.y,Poly);
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Pnt:TPoint3D):TPoint3D;
Begin
 Result.x := Pnt.x + Dx;
 Result.y := Pnt.y + Dy;
 Result.z := Pnt.z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Ln:TLine3D):TLine3D;
Begin
 Result[1].x := Ln[1].x + Dx;
 Result[1].y := Ln[1].y + Dy;
 Result[1].z := Ln[1].z + Dz;
 Result[2].x := Ln[2].x + Dx;
 Result[2].y := Ln[2].y + Dy;
 Result[2].z := Ln[2].z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Seg:TSegment3D):TSegment3D;
Begin
 Result[1].x := Seg[1].x + Dx;
 Result[1].y := Seg[1].y + Dy;
 Result[1].z := Seg[1].z + Dz;
 Result[2].x := Seg[2].x + Dx;
 Result[2].y := Seg[2].y + Dy;
 Result[2].z := Seg[2].z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Tri:TTriangle3D):TTriangle3D;
Begin
 Result[1].x := Tri[1].x + Dx;
 Result[1].y := Tri[1].y + Dy;
 Result[1].z := Tri[1].z + Dz;
 Result[2].x := Tri[2].x + Dx;
 Result[2].y := Tri[2].y + Dy;
 Result[2].z := Tri[2].z + Dz;
 Result[3].x := Tri[3].x + Dx;
 Result[3].y := Tri[3].y + Dy;
 Result[3].z := Tri[3].z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Quad:TQuadix3D):TQuadix3D;
Begin
 Result[1].x := Quad[1].x + Dx;
 Result[1].y := Quad[1].y + Dy;
 Result[1].z := Quad[1].z + Dz;
 Result[2].x := Quad[2].x + Dx;
 Result[2].y := Quad[2].y + Dy;
 Result[2].z := Quad[2].z + Dz;
 Result[3].x := Quad[3].x + Dx;
 Result[3].y := Quad[3].y + Dy;
 Result[3].z := Quad[3].z + Dz;
 Result[4].x := Quad[4].x + Dx;
 Result[4].y := Quad[4].y + Dy;
 Result[4].z := Quad[4].z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Sphere:TSphere):TSphere;
Begin
 Result.x := Sphere.x + Dx;
 Result.y := Sphere.y + Dy;
 Result.z := Sphere.z + Dz;
End;
(* End Of Translate *)


Function Translate(Dx,Dy,Dz:TJmFloat; Poly: TPolygon3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 to Length(Poly)-1 do
  Begin
   Result[I].x := Poly[I].x + Dx;
   Result[I].y := Poly[I].y + Dy;
   Result[I].z := Poly[I].z + Dz;
  End;
End;
(* End Of Translate *)


Function Translate(Pnt:TPoint3D; Poly: TPolygon3D):TPolygon3D;
Begin
 Result := Translate(Pnt.x,Pnt.y,Pnt.z,Poly);
End;
(* End Of Translate *)


Function Scale(Dx,Dy:TJmFloat; Pnt:TPoint2D):TPoint2D;
Begin
 Result.x := Pnt.x * Dx;
 Result.y := Pnt.y * Dy;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Ln:TLine2D):TLine2D;
Begin
 Result[1].x := Ln[1].x * Dx;
 Result[1].y := Ln[1].y * Dy;
 Result[2].x := Ln[2].x * Dx;
 Result[2].y := Ln[2].y * Dy;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Seg:TSegment2D):TSegment2D;
Begin
 Result[1].x := Seg[1].x * Dx;
 Result[1].y := Seg[1].y * Dy;
 Result[2].x := Seg[1].x * Dx;
 Result[2].y := Seg[2].y * Dy;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1].x := Tri[1].x * Dx;
 Result[1].y := Tri[1].y * Dy;
 Result[2].x := Tri[2].x * Dx;
 Result[2].y := Tri[2].y * Dy;
 Result[3].x := Tri[3].x * Dx;
 Result[3].y := Tri[3].y * Dy;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1].x := Quad[1].x * Dx;
 Result[1].y := Quad[1].y * Dy;
 Result[2].x := Quad[2].x * Dx;
 Result[2].y := Quad[2].y * Dy;
 Result[3].x := Quad[3].x * Dx;
 Result[3].y := Quad[3].y * Dy;
 Result[4].x := Quad[4].x * Dx;
 Result[4].y := Quad[4].y * Dy;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Rec:TRectangle):TRectangle;
Begin
 Result[1].x := Rec[1].x * Dx;
 Result[1].y := Rec[1].y * Dy;
 Result[2].x := Rec[2].x * Dx;
 Result[2].y := Rec[2].y * Dy;
End;
(* End Of Scale*)


Function Scale(Dr:TJmFloat; Cir:TCircle):TCircle;
Begin
 Result.x      := Cir.x;
 Result.y      := Cir.y;
 Result.Radius := Cir.Radius*Dr;
End;
(* End Of Scale*)


Function Scale(Dx,Dy:TJmFloat; Poly: TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Result[I].x := Poly[I].x * Dx;
   Result[I].y := Poly[I].y * Dy;
  End;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Pnt:TPoint3D):TPoint3D;
Begin
 Result.x := Pnt.x * Dx;
 Result.y := Pnt.y * Dy;
 Result.z := Pnt.z * Dz;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Ln:TLine3D):TLine3D;
Begin
 Result[1].x := Ln[1].x * Dx;
 Result[1].y := Ln[1].y * Dy;
 Result[1].z := Ln[1].z * Dz;
 Result[2].x := Ln[2].x * Dx;
 Result[2].y := Ln[2].y * Dy;
 Result[2].z := Ln[2].z * Dz;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Seg:TSegment3D):TSegment3D;
Begin
 Result[1].x := Seg[1].x * Dx;
 Result[1].y := Seg[1].y * Dy;
 Result[1].z := Seg[1].z * Dz;
 Result[2].x := Seg[2].x * Dx;
 Result[2].y := Seg[2].y * Dy;
 Result[2].z := Seg[2].z * Dz;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Tri:TTriangle3D):TTriangle3D;
Begin
 Result[1].x := Tri[1].x * Dx;
 Result[1].y := Tri[1].y * Dy;
 Result[1].z := Tri[1].z * Dz;
 Result[2].x := Tri[2].x * Dx;
 Result[2].y := Tri[2].y * Dy;
 Result[2].z := Tri[2].z * Dz;
 Result[3].x := Tri[3].x * Dx;
 Result[3].y := Tri[3].y * Dy;
 Result[3].z := Tri[3].z * Dz;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Quad:TQuadix3D):TQuadix3D;
Begin
 Result[1].x := Quad[1].x * Dx;
 Result[1].y := Quad[1].y * Dy;
 Result[1].z := Quad[1].z * Dz;
 Result[2].x := Quad[2].x * Dx;
 Result[2].y := Quad[2].y * Dy;
 Result[2].z := Quad[2].z * Dz;
 Result[3].x := Quad[3].x * Dx;
 Result[3].y := Quad[3].y * Dy;
 Result[3].z := Quad[3].z * Dz;
 Result[4].x := Quad[4].x * Dx;
 Result[4].y := Quad[4].y * Dy;
 Result[4].z := Quad[4].z * Dz;
End;
(* End Of Scale*)


Function Scale(Dr:TJmFloat; Sphere:TSphere):TSphere;
Begin
 Result.x      := Sphere.x;
 Result.y      := Sphere.y;
 Result.z      := Sphere.z;
 Result.Radius := Sphere.Radius*Dr;
End;
(* End Of Scale*)


Function Scale(Dx,Dy,Dz:TJmFloat; Poly: TPolygon3D):TPolygon3D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Result[I].x := Poly[I].x*Dx;
   Result[I].y := Poly[I].y*Dy;
  End;
End;
(* End Of Scale*)


Procedure ShearXAxis(Shear,x,y:TJmFloat; Var Nx,Ny:TJmFloat);
Begin
 Nx := x + Shear * y;
 Ny := y;
End;
(* End Of Shear Cartesian Coordiante Along X-Axis *)


Function ShearXAxis(Shear:TJmFloat; Pnt:TPoint2D):TPoint2D;
Begin
 Result := ShearXAxis(Shear,Pnt);
End;
(* End Of Shear 2D Point Along X-Axis *)


Function ShearXAxis(Shear:TJmFloat; Seg:TSegment2D):TSegment2D;
Begin
 Result[1] := ShearXAxis(Shear,Seg[1]);
 Result[2] := ShearXAxis(Shear,Seg[2]);
End;
(* End Of Shear 2D Segment Along X-Axis *)


Function ShearXAxis(Shear:TJmFloat; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1] := ShearXAxis(Shear,Tri[1]);
 Result[2] := ShearXAxis(Shear,Tri[2]);
 Result[3] := ShearXAxis(Shear,Tri[2]);
End;
(* End Of Shear 2D Triangle Along X-Axis *)


Function ShearXAxis(Shear:TJmFloat; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1] := ShearXAxis(Shear,Quad[1]);
 Result[2] := ShearXAxis(Shear,Quad[2]);
 Result[3] := ShearXAxis(Shear,Quad[2]);
 Result[3] := ShearXAxis(Shear,Quad[2]);
End;
(* End Of Shear 2D Quadix Along X-Axis *)


Function ShearXAxis(Shear:TJmFloat; Poly:TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := ShearXAxis(Shear,Poly[I]);
  End;
 Result := Poly;
End;
(* End Of Shear 2D Polygon Along X-Axis *)


Procedure ShearYAxis(Shear,x,y:TJmFloat; Var Nx,Ny:TJmFloat);
Begin
 Nx := x;
 Ny := x * Shear + y;
End;
(* End Of Shear Cartesian Coordiante Along Y-Axis *)


Function ShearYAxis(Shear:TJmFloat; Pnt:TPoint2D):TPoint2D;
Begin
 Result := ShearYAxis(Shear,Pnt);
End;
(* End Of Shear 2D Point Along Y-Axis *)


Function ShearYAxis(Shear:TJmFloat; Seg:TSegment2D):TSegment2D;
Begin
 Result[1] := ShearYAxis(Shear,Seg[1]);
 Result[2] := ShearYAxis(Shear,Seg[2]);
End;
(* End Of Shear 2D Segment Along Y-Axis *)


Function ShearYAxis(Shear:TJmFloat; Tri:TTriangle2D):TTriangle2D;
Begin
 Result[1] := ShearYAxis(Shear,Tri[1]);
 Result[2] := ShearYAxis(Shear,Tri[2]);
 Result[3] := ShearYAxis(Shear,Tri[2]);
End;
(* End Of Shear 2D Triangle Along Y-Axis *)


Function ShearYAxis(Shear:TJmFloat; Quad:TQuadix2D):TQuadix2D;
Begin
 Result[1] := ShearYAxis(Shear,Quad[1]);
 Result[2] := ShearYAxis(Shear,Quad[2]);
 Result[3] := ShearYAxis(Shear,Quad[2]);
 Result[3] := ShearYAxis(Shear,Quad[2]);
End;
(* End Of Shear 2D Quadix Along X-Axis *)


Function ShearYAxis(Shear:TJmFloat; Poly:TPolygon2D):TPolygon2D;
Var I:Integer;
Begin
 For I:= 0 To Length(Poly)-1 Do
  Begin
   Poly[I] := ShearYAxis(Shear,Poly[I]);
  End;
 Result := Poly;
End;
(* End Of Shear 2D Polygon Along Y-Axis *)


Function EquatePoint(x,y:TJmFloat):TPoint2D;
Begin
 Result.x := x;
 Result.y := y;
End;
(* End Of EquatePoint *)


Function EquatePoint(x,y,z:TJmFloat):TPoint3D;
Begin
 Result.x := x;
 Result.y := y;
 Result.z := z;
End;
(* End Of EquatePoint *)


Function EquateSegment(x1,y1,x2,y2:TJmFloat):TSegment2D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[1].y := y1;
 Result[2].y := y2;
End;
(* End Of EquateLine *)


Function EquateSegment(x1,y1,z1,x2,y2,z2:TJmFloat):TSegment3D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[1].y := y1;
 Result[2].y := y2;
 Result[1].z := z1;
 Result[2].z := z2;
End;
(* End Of EquateLine *)


Function EquateQuadix(x1,y1,x2,y2,x3,y3,x4,y4:TJmFloat):TQuadix2D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[3].x := x3;
 Result[4].x := x4;
 Result[1].y := y1;
 Result[2].y := y2;
 Result[3].y := y3;
 Result[4].y := y4;
End;
(* End Of EquateQuadix *)


Function EquateQuadix(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:TJmFloat):TQuadix3D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[3].x := x3;
 Result[4].x := x4;
 Result[1].y := y1;
 Result[2].y := y2;
 Result[3].y := y3;
 Result[4].y := y4;
 Result[1].z := z1;
 Result[2].z := z2;
 Result[3].z := z3;
 Result[4].z := z4;
End;
(* End Of EquateQuadix *)


Function EquateRectangle(x1,y1,x2,y2:TJmFloat):TRectangle;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[1].y := y1;
 Result[2].y := y2;
End;
(* End Of EquateRectangle *)


Function EquateTriangle(x1,y1,x2,y2,x3,y3:TJmFloat):TTriangle2D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[3].x := x3;
 Result[1].y := y1;
 Result[2].y := y2;
 Result[3].y := y3;
End;
(* End Of EquateTriangle *)


Function EquateTriangle(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TTriangle3D;
Begin
 Result[1].x := x1;
 Result[2].x := x2;
 Result[3].x := x3;
 Result[1].y := y1;
 Result[2].y := y2;
 Result[3].y := y3;
 Result[1].z := z1;
 Result[2].z := z2;
 Result[3].z := z3;
End;
(* End Of EquateTriangle *)

Function EquateTriangle(Pnt1,Pnt2,Pnt3: TPoint2D):TTriangle2D;
Begin
 Result[1] := Pnt1;
 Result[2] := Pnt2;
 Result[3] := Pnt3;
End;
(* End Of EquateTriangle *)


Function EquateTriangle(Pnt1,Pnt2,Pnt3: TPoint3D):TTriangle3D;
Begin
 Result[1] := Pnt1;
 Result[2] := Pnt2;
 Result[3] := Pnt3;
End;
(* End Of EquateTriangle *)


Function EquateCircle(x,y,r:TJmFloat):TCircle;
Begin
 Result.x      := x;
 Result.y      := y;
 Result.Radius := r;
End;
(* End Of EquateCircle *)


Function EquateSphere(x,y,z,r:TJmFloat):TSphere;
Begin
 Result.x      := x;
 Result.y      := y;
 Result.z      := z;
 Result.Radius := r;
End;
(* End Of EquateSphere *)



Function EquatePlane(x1,y1,z1,x2,y2,z2,x3,y3,z3:TJmFloat):TPlane3D;
Begin
 Result.a := y1 * (z2 - z3) + y2 * (z3 - z1) + y3 * (z1 - z2);
 Result.b := z1 * (x2 - x3) + z2 * (x3 - x1) + z3 * (x1 - x2);
 Result.c := x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2);
 Result.d := -(x1*(y2 * z3 - y3 * z2) + x2*(y3 * z1 - y1 * z3) + x3 * (y1 * z2 -y2 * z1));
End;
(* End Of EquatePlane *)


Function EquatePlane(Pnt1,Pnt2,Pnt3:TPoint3D):TPlane3D;
Begin
 Result := EquatePlane(Pnt1.x,Pnt1.y,Pnt1.z,Pnt2.x,Pnt2.y,Pnt2.z,Pnt3.x,Pnt3.y,Pnt3.z);
End;
(* End Of EquatePlane *)


Procedure GenerateRandomPoints(Bx1,By1,Bx2,By2:TJmFloat; Var Point: Array Of TPoint2D);
Var I     : LongInt;
    Dx,Dy : Integer;
    Len   : LongInt;
Begin
 Randomize;
 Len := Length(Point);
 Dx  := Round(Abs(Bx2 - Bx1));
 Dy  := Round(Abs(By2 - By1));
 For I:= 0 To Len-1 Do
  Begin
   Point[I].x := Bx1 + Random(Dx);
   Point[I].y := By1 + Random(Dy);
  End;
End;
(* End Generate Random Points *)


(*****************************************************************************)
(********************** Vector Class Implementation **************************)
(*****************************************************************************)

Function Add(Vec1,Vec2:TVector2D):TVector2D;
Begin
 Result.x := Vec1.x + Vec2.x;
 Result.y := Vec1.y + Vec2.y;
End;
(* End Of Add *)


Function Add(Vec1,Vec2:TVector3D):TVector3D;
Begin
 Result.x := Vec1.x + Vec2.x;
 Result.y := Vec1.y + Vec2.y;
 Result.z := Vec1.z + Vec2.z;
End;
(* End Of Add *)


Function Sub(Vec1,Vec2:TVector2D):TVector2D;
Begin
 Result.x := Vec1.x - Vec2.x;
 Result.y := Vec1.y - Vec2.y;
End;
(* End Of Sub *)


Function Sub(Vec1,Vec2:TVector3D):TVector3D;
Begin
 Result.x := Vec1.x - Vec2.x;
 Result.y := Vec1.y - Vec2.y;
 Result.z := Vec1.z - Vec2.z;
End;
(* End Of Sub *)


Function Mul(Vec1,Vec2:TVector2D):TVector3D;
Begin

End;
(* End Of *)


Function Mul(Vec1,Vec2:TVector3D):TVector3D;
Begin
 Result.x := Vec1.y * Vec2.z - Vec1.z * Vec2.y;
 Result.y := Vec1.z * Vec2.x - Vec1.x * Vec2.z;
 Result.z := Vec1.x * Vec2.y - Vec1.y * Vec2.x;
End;
(* End Of Multiply (cross-product) *)


Function UnitVector(Vec:TVector2D):TVector2D;
Var Mag: TJmFloat;
Begin
 Mag      := Magnitude(Vec);
 Result.x := Vec.x / Mag;
 Result.y := Vec.y / Mag;
End;
(* End Of UnitVector *)


Function UnitVector(Vec:TVector3D):TVector3D;
Var Mag: TJmFloat;
Begin
 Mag      := Magnitude(Vec);
 Result.x := Vec.x / Mag;
 Result.y := Vec.y / Mag;
 Result.z := Vec.z / Mag;
End;
(* End Of UnitVector *)


Function Magnitude(Vec:TVector2D):TJmFloat;
Begin
 Result := Sqrt((Vec.x*Vec.x)+(Vec.y*Vec.y));
End;
(* End Of Magnitude *)


Function Magnitude(Vec:TVector3D):TJmFloat;
Begin
 Result := Sqrt((Vec.x*Vec.x)+(Vec.y*Vec.y)+(Vec.z*Vec.z));
End;
(* End Of Magnitude *)


Function DotProduct(Vec1,Vec2:TVector2D):TJmFloat;
Begin
 Result := Vec1.x*Vec2.x + Vec1.y*Vec2.y;
End;
(* End Of DotProduct *)


Function DotProduct(Vec1,Vec2:TVector3D):TJmFloat;
Begin
 Result := Vec1.x*Vec2.x + Vec1.y*Vec2.y + Vec1.z*Vec2.z;
End;
(* End Of DotProduct *)


Function Scale(Vec:TVector2D; Factor:TJmFloat):TVector2D;
Begin
 Result.x := Vec.x * Factor;
 Result.y := Vec.y * Factor;
End;
(* End Of Scale *)


Function Scale(Vec:TVector3D; Factor:TJmFloat):TVector3D;
Begin
 Result.x := Vec.x * Factor;
 Result.y := Vec.y * Factor;
 Result.z := Vec.z * Factor;
End;
(* End Of Scale *)

Function Scale(Factor:TJmFloat; Vec:TVector3D):TVector3D;
Begin
 Result.x := Vec.x * Factor;
 Result.y := Vec.y * Factor;
 Result.z := Vec.z * Factor;
End;
(* End Of Scale *)

Function Negate(Vec:TVector2D):TVector2D;
Begin
 Result.x := -Vec.x;
 Result.y := -Vec.y;
End;
(* End Of Negate *)


Function Negate(Vec:TVector3D):TVector3D;
Begin
 Result.x := -Vec.x;
 Result.y := -Vec.y;
 Result.z := -Vec.z;
End;
(* End Of Negate *)


Procedure InitialiseTrigonometryTables;
Var I:Integer;
Begin
 {
    Note: Trig tables are used to speed-up sin-cos-tan calculations
 }
 SetLength(CosTable,360);
 SetLength(SinTable,360);
 SetLength(TanTable,360);
 For I:= 0 To 359 Do
  Begin
   CosTable[I] := Cos(I*PIDiv180);
   SinTable[I] := Sin(I*PIDiv180);
   TanTable[I] := Tan(I*PIDiv180);
  End;
End;

Function IsEqual(Val1,Val2:TJmFloat):Boolean;
Var Delta:TJmFloat;
Begin
 Delta  := Abs(Val1-Val2);
 Result := (Delta <= Epsilon);
End;
(* End Of Is Equal *)


Function IsEqual(Pnt1,Pnt2:TPoint2D):Boolean;
Begin
 Result := (IsEqual(Pnt1.x,Pnt2.x) And IsEqual(Pnt1.y,Pnt2.y));
End;
(* End Of Is Equal *)


Function IsEqual(Pnt1,Pnt2:TPoint3D):Boolean;
Begin
 Result := (IsEqual(Pnt1.x,Pnt2.x) And IsEqual(Pnt1.y,Pnt2.y) And IsEqual(Pnt1.z,Pnt2.z));
End;
(* End Of Is Equal *)

Function NotEqual(Val1,Val2:TJmFloat):Boolean;
Var Delta:TJmFloat;
Begin
 Delta  := Abs(Val1-Val2);
 Result := (Delta > Epsilon);
End;
(* End Of Not Equal *)


Function NotEqual(Pnt1,Pnt2:TPoint2D):Boolean;
Begin
 Result := (NotEqual(Pnt1.x,Pnt2.x) Or NotEqual(Pnt1.y,Pnt2.y));
End;
(* End Of Not Equal *)


Function NotEqual(Pnt1,Pnt2:TPoint3D):Boolean;
Begin
 Result := (NotEqual(Pnt1.x,Pnt2.x) Or NotEqual(Pnt1.y,Pnt2.y) Or NotEqual(Pnt1.z,Pnt2.z));
End;
(* End Of Not Equal *)

 Initialization
  MaximumX         :=  1.0e300;
  MinimumX         := -1.0e300;
  MaximumY         :=  1.0e300;
  MinimumY         := -1.0e300;
  MaximumZ         :=  1.0e300;
  MinimumZ         := -1.0e300;
  PolyOrthoCenterX := 0;
  PolyOrthoCenterY := 0;
  InitialiseTrigonometryTables;

 Finalization
  CosTable := Nil;
  SinTable := Nil;

End.






