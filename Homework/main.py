import pygame
import asyncio

player1 = input("First player name: ").strip()
while not player1:
    player1 = input("Name needed: ").strip()

player2 = input("Second player name: ").strip()
while not player2:
    player2 = input("Name needed: ").strip()

petofi_age = 1823

guess1 = int(input(f"{player1}, guess when Petofi was born: "))
guess2 = int(input(f"{player2}, guess when Petofi was born: "))

diff1 = abs(guess1 - petofi_age)
diff2 = abs(guess2 - petofi_age)

if diff1 < diff2:
    print(f"{player1} wins!")
elif diff2 < diff1:
    print(f"{player2} wins!")
else:
    print("It's a tie!")

print(f"The correct answer was {petofi_age}.")

pygame.init()

screen = pygame.display.set_mode((800, 600))
clock = pygame.time.Clock()

async def main():
    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        screen.fill((0, 0, 0))

        # your game code here

        pygame.display.flip()
        clock.tick(60)

        await asyncio.sleep(0)

    pygame.quit()

asyncio.run(main())
