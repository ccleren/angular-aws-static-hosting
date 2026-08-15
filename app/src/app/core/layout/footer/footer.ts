import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Icon } from '../../../shared/icon/icon';

@Component({
  selector: 'app-footer',
  imports: [RouterLink, Icon],
  templateUrl: './footer.html',
  styleUrl: './footer.scss',
})
export class Footer {
  protected readonly year = new Date().getFullYear();
}
