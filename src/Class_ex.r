########################################################################################################
#### Fungal Biology and Ecology course | Class Exercise - Juan F. Dueñas & Judith Riedo - AG Rillig ####
########################################################################################################
#### Clean environment and create path object ####
rm(list=ls())

path <- getwd() # path to folder where the class materials are  

#### Load Packages ####
pkgs <- c("vegan", "tidyverse", "ggordiplots", "MASS")

vapply(pkgs, FUN = library, FUN.VALUE = logical(1L), logical.return = TRUE, character.only = TRUE)

#### load data sets ####
# read ASV abundance table
ab <- read_csv(paste(path,"/data/ASV_abun.rar.csv",sep=""), show_col_types=F) %>%
          rename("Samples"=1) %>%
          column_to_rownames(var = "Samples") %>%
          data.matrix

# vizualize ASV matrix
ab[1:10,1:10] #print matrix


# read experimental treatment table
md_meta <- read_csv(paste(path,"/data/meta.mp.csv", sep = ""), show_col_types = F ) %>%
           mutate(Treatment = paste(status, ':', microplastic, sep = ""))

# change labels of experimental factors to make them human readable in figures
md_meta$Treatment <- base::factor(md_meta$Treatment,
                                  levels =  c("well-watered:absent", "drought:absent","well-watered:present", "drought:present"),
                                  labels = c("Ctrl", "+Drought", "+Microplastic", "+Drought +Microplastic"))
#md_meta <- droplevels(md_meta)
md_meta # print metadata

# read taxonomic and ecological guild table 
tax <- read_csv(paste(path,"/data/taxtr_rar.csv", sep = ""), show_col_types = F) %>% 
        dplyr::select(-1) %>%
        dplyr::select(ASV_ID, Kingdom, Phylum, Genus, Species, Guild)

tax # print tax table and interesting columns

#### Alpha diversity - Kingdom Level - generalized linear models (GLMs) ####
md_meta["S"] <- specnumber(ab) # Estimate fungal richness --> why S
md_meta

# Lets just first visualize the data to have an idea
ggplot(md_meta, aes(x = Treatment, y = as.numeric(S), 
                    fill=Treatment)) +
  geom_boxplot() +
  geom_point(alpha=1, size=2) +
  geom_text(aes(label=pot_number), nudge_x = -0.15) +
  scale_y_continuous(limits = c(0,190)) +
  guides(color="none") +
  labs(x = "Treatment",
       y = "ASVs Richness") +
  theme_bw() +
  theme(text = element_text(size = 15),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")


# let's check how many reads each of these samples has
cbind(md_meta$pot_number, rowSums(ab)) 

# something looks strange here. Can you tell what is it?

# let's eliminate sample S059 (#17) from the set - it might cause trouble down the line
keep <- md_meta$pot_number
keep <- keep[-17] # get rid of sample #17
md_meta <- md_meta[keep,] # delete it from the contextual data
md_meta

ab <- ab[keep,] # delete it from the ASV abundance table
summary(colSums(ab)) # check if there are now ASVs with 0 reads - yes
del <- which(colSums(ab)==0) # get the indices of those ASVs we want to delete
ab <- ab[,-del] # delete them
summary(colSums(ab)) # check if there are now ASVs with 0 reads - no
## 1133 ASV remain. Eliminating sample 17 gets rid of three ASVs only

#Now let's recalculate richness for our dataset
md_meta["S"] <- specnumber(ab) # Estimate fungal richness 

#And plot again
ggplot(md_meta, aes(x = Treatment, y = as.numeric(S), 
                    fill=Treatment)) +
  geom_boxplot() +
  geom_point(alpha=1, size=2) +
  geom_text(aes(label=pot_number), nudge_x = -0.15) +
  scale_y_continuous(limits = c(0,190)) +
  guides(color="none") +
  labs(x = "Treatment",
       y = "ASVs Richness") +
  theme_bw() +
  theme(text = element_text(size = 15),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

# Now let's model this trends using GLMs
# Specify GLMs with negative binomial errors
m1 <- glm.nb(S ~ drought + microplastic + drought:microplastic, data = md_meta )


# lets generate predictions with the model and visualize them!
pdat <- with(md_meta,
             tibble(drought = drought,
                    microplastic = microplastic,
                    treatment = Treatment))
# predict
pred <- predict(m1, pdat, type = "link", se.fit = TRUE)
ilink <- family(m1)$linkinv # g-1()
pdat <- pdat %>%
  bind_cols(data.frame(pred)) %>%
  mutate(fitted = ilink(fit),
         upper = ilink(fit + (1.96 * se.fit)),
         lower = ilink(fit - (1.96 * se.fit)))

# plot predictions and confidence intervals
ggplot(md_meta, aes(x = Treatment, y = as.numeric(S), 
                    color=Treatment)) +
    geom_point(aes(x = treatment, y=fitted), shape=3, size=4,
               data = pdat, inherit.aes = FALSE, alpha = 0.8) +
    geom_errorbar(aes(ymin = lower, ymax = upper, x = treatment), width=0.2, 
                  data = pdat, inherit.aes = FALSE, alpha = 0.8) +
    geom_jitter(alpha = 0.5, size = 2, width = 0.15) +
    scale_y_continuous(limits = c(0,190)) +
    guides(color="none") +
    labs(x = "Treatment",
       y = "ASVs Richness") +
  theme_bw() +
  theme(text = element_text(size = 15),
        axis.text.x = element_text(angle = 45, hjust = 1))

# looking at this plot, how would you characterize the effects of microplastic and drought on fungal richness?
# Do you think the differences between control and treatments are large? do you think they are statistically significant?

# let's test if treatments induced a strong reduction in richness
summary(m1) # what is the interpretation for this? 


#### Beta diversity - Ordination - Kingdom Level ####
# transform abundance table to presence-absence
pa <- decostand(ab, method = "pa")
pa[1:10,1:10]

# calculate Jaccard distance
jac.f <- vegdist(pa, method="jac", binary=T) 
round(jac.f[1:10], 2)

# NMDS Class
(nmds.f <- metaMDS(jac.f, k=4, try = 200, parallel=2, trace=F, weakties=F))
stressplot(nmds.f)
sppscores(nmds.f) <- pa

# extract sample scores to plot with ggplot2
NMDS.f <- gg_ordiplot (nmds.f, groups = md_meta$Treatment, hull = F, label = F,
                       spiders = F, ellipse = T, plot = F, choices = c(1, 2), scaling=1)

points <-cbind(NMDS.f$df_ord) # extracts points
colnames(points) <- c("x", "y", "Treatment")

# extract ellipses
elip <- NMDS.f$df_ellipse
colnames(elip) <- c("Treatment", "x","y")
elip$Treatment <- factor(elip$Treatment, levels = c("Ctrl", "+Drought", "+Microplastic", "+Drought +Microplastic")) #Attention, this needs to be done otherwise fills will not match

#plot with ggplots
nmds.p.f <- ggplot()
(nmds.p.f <- nmds.p.f + 
             geom_point(data=points, aes(x=x, y=y, color=Treatment), alpha=0.5,  size=3, show.legend = T) +
             geom_path(data=elip, aes(x=x, y=y, colour=Treatment),show.legend = T, size=1) +
             geom_vline(xintercept=0.0, color="Grey", size=0.8, linetype=2) +
             geom_hline(yintercept=0.0, color="Grey", size=0.8, linetype=2) +
             labs(title="Fungal comm. disimilarity", x="Axis 1", y="Axis 2") +
             theme_bw() +
             theme(plot.title = element_text(hjust = 0.5, size = 15),
                   axis.title = element_text(size = 15),
                   legend.key = element_blank(),  #removes the box around each legend item
                   legend.position = "bottom", #legend at the bottom
                   legend.text = element_text(size=15),
                   legend.title = element_blank(),
                   panel.border = element_rect(colour = "Black", fill = F),
                   panel.grid = element_blank()))

# add polygons within the ellipse boundaries
(nmds.p.f <- nmds.p.f + 
             geom_polygon(data=elip, aes(x=x, y=y, fill=Treatment),show.legend = T, size=1, alpha=0.2))


#Do you see any clusters in this plot? 
#What does that indicate?

# Let's test if our treatments explain a significant portion of the variation in community structure observed in the ordination

# Redundancy Analysis
rda.f <- rda(pa ~ microplastic + drought + microplastic:drought , data=md_meta, center=T)

# Permutation Tests
(rda.term <- anova.cca(rda.f, permutations = 999, by="term", model = "reduced"))

## end of script - Now it is your turn.

# clean up 
rm(list = setdiff(ls(), c("path", "ab", "md_meta", "tax")))

