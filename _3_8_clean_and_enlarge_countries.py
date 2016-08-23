import ogr,sys,math, random,os
import numpy as np

  

def Clean_Enlarge_Polygon(geom):  
    #classify country type and flag the strategy
    country_type = 0 #undefined
    for i in range(0, geom.GetGeometryCount()): #iterate over rings
       g = geom.GetGeometryRef(i)
       if g.Area() > 10*DEL_AREA:
           country_type = 1 #"big" country, clean small holes
    if country_type == 0:
        country_type = 2 # small one polygon country, enlarge
    out_geom = ogr.Geometry(ogr.wkbPolygon)
    if country_type == 1:
        for i in range(0, geom.GetGeometryCount()): #iterate over rings
            g = geom.GetGeometryRef(i)
            if g.Area() > DEL_AREA:
                out_geom.AddGeometry(g)           
    if country_type == 2:
        g = geom.GetGeometryRef(0) #it is already small country, keep only outer ring
        c = geom.Centroid()
        ratio = math.sqrt(DEL_AREA/g.Area())#enlarge by 5 times, change if necessary, see e.g. Vatican City
        if ratio >1:
            for j in range(0,g.GetPointCount()):
                p=g.GetPoint(j)  
                dx = (p[0] - c.GetX())*ratio
                dy = (p[1] - c.GetY())*ratio
                dist_ratio = math.sqrt(dx*dx+dy*dy)/TOL_LENGTH
                if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                    dx = dx/dist_ratio
                    dy = dy/dist_ratio
                if (dx*dx+dy*dy) != 0.0:
                    dist_ratio = 0.5*TOL_LENGTH/math.sqrt(dx*dx+dy*dy)
                    if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                        dx = dx*dist_ratio
                        dy = dy*dist_ratio
                g.SetPoint(j,c.GetX()+dx,c.GetY()+dy)
        out_geom.AddGeometry(g)
    return country_type,out_geom

def Clean_Enlarge_MultiPolygon(geom):  
    #classify country type and choose the strategy
    country_type = 0 #undefined
    for i in range(0, geom.GetGeometryCount()): #iterate over polygons in multipolygon structure
       g = geom.GetGeometryRef(i)
       if g.Area() > 10*DEL_AREA: #there is polygon which can be shown in map scale
           country_type = 1 #"big" country, clean small islands
    if country_type == 0 and geom.GetGeometryCount()==1: #there is one small polygon
        country_type = 2 # small one polygon country, enlarge
    if country_type == 0 and geom.GetGeometryCount()>1: #there are two or more small polygons
        country_type = 3 # country made of small islands, keep n-largest, enlarge them, clean rest

    out_geom = ogr.Geometry(ogr.wkbMultiPolygon)
    if country_type == 1:
        for i in range(0, geom.GetGeometryCount()): #iterate over polygons
            g = geom.GetGeometryRef(i)
            if g.Area() > DEL_AREA: #polygon is large enough to keep on map
                poly = ogr.Geometry(ogr.wkbPolygon)
                for k in range(0,g.GetGeometryCount()): #keep only rings large enough to show on map, this will clean small enclaves
                    r = g.GetGeometryRef(k)
                    if r.Area() > DEL_AREA:
                        poly.AddGeometry(r)
                out_geom.AddGeometry(poly)           
    if country_type == 2:
            g = geom.GetGeometryRef(0)
            c = geom.Centroid()
            ratio = DEL_AREA*0.2/g.Area() #enlarge area to five times of the smallest area i.e. DEL_AREA, e.g. Vatican City
            if ratio > 1:
                for j in range(0,g.GetPointCount()):
                    p=g.GetPoint(j)  
                    dx = (p[0] - c.GetX())*ratio
                    dy = (p[1] - c.GetY())*ratio
                    dist_ratio = math.sqrt(dx*dx+dy*dy)/3*TOL_LENGTH
                    if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                        dx = dx/dist_ratio
                        dy = dy/dist_ratio
                    if (dx*dx+dy*dy) != 0.0:
                        dist_ratio = 0.5*TOL_LENGTH/math.sqrt(dx*dx+dy*dy)
                        if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                            dx = dx*dist_ratio
                            dy = dy*dist_ratio
                    g.SetPoint(j,c.GetX()+dx,c.GetY()+dy)
            out_geom.AddGeometry(g)
    if country_type == 3:
        island = 0
        area = np.zeros(geom.GetGeometryCount())
        for i in range(0, geom.GetGeometryCount()): #calculate polygons area
            g = geom.GetGeometryRef(i)
            if g.Area()>0:
                area[i] = 1.0/g.Area()
            else:
                area[i] = 0
            
        #print area
        area_sort = np.argsort(area) #sort polygons from largest to smallest area
        #print area_sort

        for i in range(0, geom.GetGeometryCount()): #iterate over polygons
            g = geom.GetGeometryRef(area_sort[i])
            r = g.GetGeometryRef(0) #consider only outer ring
            ratio = math.sqrt(DEL_AREA/r.Area())
            c = g.Centroid()
            if ratio < 3 or island < 3: #do not enlarge very small islands (< 0.5* DEL_AREA) except, if only such small island exists, enlarge anyway and keep largest one  
              if not (island > 0 and ratio > 5): 
                if ratio < 1:
                    ratio = 1 
                if ratio > 2:
                    ratio = ratio*0.5
                island = island + 1
                for k in range(0,r.GetPointCount()):
                    p=r.GetPoint(k)  
                    dx = (p[0] - c.GetX())*ratio
                    dy = (p[1] - c.GetY())*ratio
                    #dist_ratio = math.sqrt(dx*dx+dy*dy)/(6.0*TOL_LENGTH)
                    #if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                    #    dx = dx/dist_ratio
                    #    dy = dy/dist_ratio
                    if (dx*dx+dy*dy) != 0.0:
                        dist_ratio = 0.2*TOL_LENGTH/math.sqrt(dx*dx+dy*dy)
                        if dist_ratio > 1:  #make shape more round in case that shape is very elongated
                            dx = dx*dist_ratio
                            dy = dy*dist_ratio
                    r.SetPoint(k,c.GetX()+dx,c.GetY()+dy)
                poly = ogr.Geometry(ogr.wkbPolygon)
                poly.AddGeometry(r)
                out_geom.AddGeometry(poly)
    return country_type,out_geom

#start of main program
scale = float(sys.argv[1])
small_area = float(sys.argv[2])
DEL_AREA = (scale/1000)*(scale/1000)*small_area #small area in map units
TOL_LENGTH = scale/2300 #main paramater of the algorithm
SQR_TOL_LENGTH = TOL_LENGTH*TOL_LENGTH #squared main parameter of the algorithm
ZERO_EPSILON = 1E-12 # treat as zero
MIN_ANGLE = 150.*math.pi/180.
SQR_SMOOTH_LENGTH = 20.*SQR_TOL_LENGTH
ZERO_AREA = 1E-6

driver = ogr.GetDriverByName('ESRI Shapefile')
inDataSet = driver.Open(sys.argv[3], 0)

inLayer = inDataSet.GetLayer()

if os.path.exists(sys.argv[4]):
    driver.DeleteDataSource(sys.argv[4])
outDataSet = driver.CreateDataSource(sys.argv[4])
outLayer = outDataSet.CreateLayer(inLayer.GetName(), geom_type=inLayer.GetGeomType(),options=['ENCODING=UTF8'])

# add fields
inLayerDefn = inLayer.GetLayerDefn()
for i in range(0, inLayerDefn.GetFieldCount()):
    fieldDefn = inLayerDefn.GetFieldDefn(i)
    outLayer.CreateField(fieldDefn)

# get the output layer's feature definition
outLayerDefn = outLayer.GetLayerDefn()
n = 0
for inFeature in inLayer:
    geom = inFeature.GetGeometryRef()
    if geom.GetGeometryName() == 'POLYGON':
        flag,out_geom = Clean_Enlarge_Polygon(geom)
        n = n+1
        #print flag
    elif geom.GetGeometryName() == 'MULTIPOLYGON':
        flag,out_geom = Clean_Enlarge_MultiPolygon(geom)
        n = n+1
        #print flag
    outFeature = ogr.Feature(outLayerDefn)
    # set the geometry and attribute
    outFeature.SetGeometry(out_geom)
    for i in range(0, outLayerDefn.GetFieldCount()):
        outFeature.SetField(outLayerDefn.GetFieldDefn(i).GetNameRef(), inFeature.GetField(i))
    # add the feature to the shapefile
    outLayer.CreateFeature(outFeature)
    # destroy the features and get the next input feature
    outFeature.Destroy()
    inFeature.Destroy()
print "Final number of countries: ",n   
#create .prj file
spatialRef = inLayer.GetSpatialRef()
spatialRef.MorphToESRI()
file = open(os.path.splitext(sys.argv[4])[0]+'.prj', 'w')
file.write(spatialRef.ExportToWkt())
file.close()

inDataSet.Destroy()
outDataSet.Destroy()
